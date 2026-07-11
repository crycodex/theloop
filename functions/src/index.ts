import {GoogleGenAI, Modality} from "@google/genai";
import type {Request, Response} from "express";
import {getApps, initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {FieldValue, getFirestore} from "firebase-admin/firestore";

const firestoreDatabaseId = "default";

function userFirestore() {
  return getFirestore(getApps()[0], firestoreDatabaseId);
}
import {setGlobalOptions} from "firebase-functions/v2";
import {defineSecret} from "firebase-functions/params";
import {onRequest} from "firebase-functions/v2/https";

if (getApps().length === 0) {
  initializeApp();
}

setGlobalOptions({region: "us-central1", maxInstances: 10});

const geminiApiKey = defineSecret("GEMINI_API_KEY");
const liveModel = "gemini-3.1-flash-live-preview";
const reportModels = [
  "gemini-3.5-flash",
  "gemini-flash-latest",
  "gemini-flash-lite-latest",
];

type TranscriptTurn = {
  role: "candidate" | "interviewer";
  text: string;
};

type InterviewReport = {
  role: string;
  summary: string;
  strengths: string[];
  improvements: string[];
  score: number;
  recommendation: string;
  memorySummary: string;
};

function applyCors(response: Response): void {
  response.set("Access-Control-Allow-Origin", "*");
  response.set("Access-Control-Allow-Headers", "Authorization, Content-Type");
  response.set("Access-Control-Allow-Methods", "POST, OPTIONS");
}

async function authenticatedUid(request: Request): Promise<string> {
  const authorization = request.header("authorization") ?? "";
  if (!authorization.startsWith("Bearer ")) {
    throw new HttpError(401, "Se requiere autenticación.");
  }

  try {
    const token = authorization.substring("Bearer ".length);
    return (await getAuth().verifyIdToken(token)).uid;
  } catch {
    throw new HttpError(401, "La sesión no es válida.");
  }
}

class HttpError extends Error {
  constructor(
    readonly status: number,
    message: string,
  ) {
    super(message);
  }
}

function sendError(response: Response, error: unknown): void {
  if (error instanceof HttpError) {
    response.status(error.status).json({error: error.message});
    return;
  }
  console.error(error);
  response.status(500).json({error: "No se pudo completar la solicitud."});
}

function cleanText(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function profilePrompt(
  profile: FirebaseFirestore.DocumentData,
  previous?: FirebaseFirestore.DocumentData,
): string {
  const name = cleanText(profile.name) || "el candidato";
  const goal =
    cleanText(profile.goal) === "custom"
      ? cleanText(profile.customGoal) || "un nuevo puesto"
      : cleanText(profile.goal) || "un nuevo puesto";
  const experience = cleanText(profile.experience) || "none";
  const memory = previous
    ? [
        "",
        "Esta práctica repite una entrevista anterior.",
        `Memoria previa: ${cleanText(previous.memorySummary)}`,
        `Fortalezas previas: ${asStringList(previous.report?.strengths).join("; ")}`,
        `Áreas a mejorar: ${asStringList(previous.report?.improvements).join("; ")}`,
        "Comprueba si el candidato mejoró, sin revelar esta memoria literalmente.",
      ].join("\n")
    : "";

  return [
    "Eres un reclutador profesional realizando una entrevista de trabajo por voz, en español.",
    `El candidato se llama ${name}, su objetivo es ${goal} y su nivel de experiencia registrado es ${experience}.`,
    "Saluda brevemente usando su nombre y confirma el rol objetivo.",
    "Haz exactamente 3 preguntas relevantes, UNA A LA VEZ, esperando siempre la respuesta antes de continuar.",
    "Mantén cada intervención corta. No enumeres preguntas futuras.",
    "Al terminar la tercera respuesta, despídete brevemente; el reporte se generará por separado.",
    memory,
  ].join("\n");
}

function asStringList(value: unknown): string[] {
  if (!Array.isArray(value)) return [];
  return value
    .filter((item: unknown): item is string => typeof item === "string")
    .map((item) => item.trim())
    .filter(Boolean);
}

export const createLiveToken = onRequest(
  {secrets: [geminiApiKey], timeoutSeconds: 30},
  async (request, response) => {
    applyCors(response);
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "POST") {
      response.status(405).json({error: "Método no permitido."});
      return;
    }

    try {
      const uid = await authenticatedUid(request);
      const userRef = userFirestore().collection("users").doc(uid);
      const profile = (await userRef.get()).data();
      if (!profile) throw new HttpError(404, "No se encontró el perfil.");

      const sourceLoopId = cleanText(request.body?.sourceLoopId);
      let previous: FirebaseFirestore.DocumentData | undefined;
      if (sourceLoopId) {
        previous = (
          await userRef.collection("loops").doc(sourceLoopId).get()
        ).data();
        if (!previous || previous.status !== "completed") {
          throw new HttpError(404, "No se encontró la práctica anterior.");
        }
      }

      const prompt = profilePrompt(profile, previous);
      const ai = new GoogleGenAI({apiKey: geminiApiKey.value()});
      const now = Date.now();
      const token = await ai.authTokens.create({
        config: {
          uses: 1,
          expireTime: new Date(now + 30 * 60 * 1000).toISOString(),
          newSessionExpireTime: new Date(now + 60 * 1000).toISOString(),
          liveConnectConstraints: {
            model: liveModel,
            config: {
              responseModalities: [Modality.AUDIO],
              systemInstruction: {
                parts: [{text: prompt}],
              },
            },
          },
          httpOptions: {apiVersion: "v1alpha"},
        },
      });

      const loopRef = userRef.collection("loops").doc();
      await loopRef.set({
        status: "active",
        sourceLoopId: sourceLoopId || null,
        profileSnapshot: {
          name: cleanText(profile.name),
          goal: cleanText(profile.goal),
          customGoal: cleanText(profile.customGoal) || null,
          experience: cleanText(profile.experience),
        },
        startedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      response.json({
        token: token.name,
        loopId: loopRef.id,
        model: liveModel,
        systemPrompt: prompt,
      });
    } catch (error) {
      sendError(response, error);
    }
  },
);

export const generateInterviewReport = onRequest(
  {secrets: [geminiApiKey], timeoutSeconds: 120},
  async (request, response) => {
    applyCors(response);
    if (request.method === "OPTIONS") {
      response.status(204).send("");
      return;
    }
    if (request.method !== "POST") {
      response.status(405).json({error: "Método no permitido."});
      return;
    }

    try {
      const uid = await authenticatedUid(request);
      const loopId = cleanText(request.body?.loopId);
      const rawTranscript = request.body?.transcript;
      if (!loopId || !Array.isArray(rawTranscript)) {
        throw new HttpError(400, "Faltan el loop o la transcripción.");
      }

      const transcript: TranscriptTurn[] = rawTranscript
        .map((turn: unknown) => normalizeTurn(turn))
        .filter((turn: TranscriptTurn | null): turn is TranscriptTurn =>
          Boolean(turn),
        );
      if (transcript.length === 0) {
        throw new HttpError(400, "La transcripción está vacía.");
      }

      const loopRef = userFirestore()
        .collection("users")
        .doc(uid)
        .collection("loops")
        .doc(loopId);
      const loop = await loopRef.get();
      if (!loop.exists) throw new HttpError(404, "No se encontró la llamada.");

      const report = await generateReport(transcript);
      const durationSeconds = Number(request.body?.durationSeconds) || 0;
      await loopRef.update({
        status: "completed",
        transcript,
        report: {
          role: report.role,
          summary: report.summary,
          strengths: report.strengths,
          improvements: report.improvements,
          score: report.score,
          recommendation: report.recommendation,
        },
        memorySummary: report.memorySummary,
        durationSeconds: Math.max(0, Math.round(durationSeconds)),
        endedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });

      response.json({loopId, report});
    } catch (error) {
      sendError(response, error);
    }
  },
);

function normalizeTurn(value: unknown): TranscriptTurn | null {
  if (!value || typeof value !== "object") return null;
  const turn = value as Record<string, unknown>;
  const role = turn.role;
  const text = cleanText(turn.text);
  if ((role !== "candidate" && role !== "interviewer") || !text) return null;
  return {role, text};
}

async function generateReport(
  transcript: TranscriptTurn[],
): Promise<InterviewReport> {
  const ai = new GoogleGenAI({apiKey: geminiApiKey.value()});
  const conversation = transcript
    .map((turn) => `${turn.role === "candidate" ? "Candidato" : "Reclutador"}: ${turn.text}`)
    .join("\n");
  const prompt = [
    "Analiza esta entrevista y responde exclusivamente con JSON válido.",
    "Esquema: {\"role\":string,\"summary\":string,\"strengths\":string[],\"improvements\":string[],\"score\":number,\"recommendation\":string,\"memorySummary\":string}.",
    "El puntaje debe estar entre 1 y 10. Escribe todo en español.",
    "memorySummary debe ser breve y útil para personalizar una repetición futura.",
    "",
    conversation,
  ].join("\n");

  let lastError: unknown;
  for (const model of reportModels) {
    for (let attempt = 0; attempt < 2; attempt++) {
      try {
        const result = await ai.models.generateContent({
          model,
          contents: prompt,
          config: {responseMimeType: "application/json"},
        });
        return parseReport(result.text ?? "");
      } catch (error) {
        lastError = error;
        if (!isRetryable(error)) break;
        await new Promise((resolve) => setTimeout(resolve, 500 * (attempt + 1)));
      }
    }
  }
  throw lastError ?? new Error("No report model was available.");
}

function isRetryable(error: unknown): boolean {
  const status = (error as {status?: number})?.status;
  return status === 429 || status === 503;
}

function parseReport(value: string): InterviewReport {
  const parsed = JSON.parse(
    value.replace(/^```json\s*/i, "").replace(/\s*```$/, ""),
  ) as Partial<InterviewReport>;
  const score = Number(parsed.score);
  return {
    role: cleanText(parsed.role) || "Entrevista laboral",
    summary: cleanText(parsed.summary),
    strengths: asStringList(parsed.strengths),
    improvements: asStringList(parsed.improvements),
    score: Number.isFinite(score) ? Math.min(10, Math.max(1, score)) : 1,
    recommendation: cleanText(parsed.recommendation),
    memorySummary: cleanText(parsed.memorySummary),
  };
}
