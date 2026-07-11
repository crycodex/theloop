import {GoogleGenAI} from "@google/genai";
import {FieldValue, Firestore} from "@google-cloud/firestore";
import type {Request, Response} from "express";
import {getApps, initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {setGlobalOptions} from "firebase-functions/v2";
import {defineSecret} from "firebase-functions/params";
import {onRequest} from "firebase-functions/v2/https";

const projectId = "the-loop-d46af";
const firestoreDatabaseId = "default";

if (getApps().length === 0) {
  initializeApp({projectId});
}

let cachedFirestore: Firestore | undefined;

function userFirestore(): Firestore {
  if (!cachedFirestore) {
    cachedFirestore = new Firestore({
      projectId,
      databaseId: firestoreDatabaseId,
    });
  }
  return cachedFirestore;
}

async function readUserProfile(uid: string) {
  const userRef = userFirestore().collection("users").doc(uid);
  const snapshot = await userRef.get();
  if (!snapshot.exists) {
    console.warn("Profile not found for uid:", uid);
    throw new HttpError(404, "No se encontró el perfil.");
  }
  console.info("Profile loaded for uid:", uid);
  return {userRef, profile: snapshot.data()!};
}

setGlobalOptions({region: "us-central1", maxInstances: 10});

const geminiApiKey = defineSecret("GEMINI_API_KEY");
const liveModel = "gemini-2.5-flash-native-audio-preview-12-2025";
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

function geminiLiveClient(apiKey: string): GoogleGenAI {
  return new GoogleGenAI({
    apiKey,
    apiVersion: "v1alpha",
  });
}

function geminiReportClient(apiKey: string): GoogleGenAI {
  return new GoogleGenAI({apiKey});
}

function resolveGeminiTokenName(token: unknown): string {
  if (!token || typeof token !== "object") return "";
  const record = token as Record<string, unknown>;
  const direct = cleanText(record.name);
  if (direct) return direct;
  const nested = record.authToken;
  if (nested && typeof nested === "object") {
    return cleanText((nested as Record<string, unknown>).name);
  }
  return "";
}

function geminiErrorMessage(error: unknown): string | undefined {
  const status = (error as {status?: number})?.status;
  const message = cleanText((error as {message?: string})?.message);
  if (status === 401 || status === 403) {
    return "La clave de Gemini no es válida o no tiene permisos.";
  }
  if (status === 404) {
    return "El modelo de voz no está disponible en tu proyecto de Gemini.";
  }
  if (message.includes("API key not valid")) {
    return "La clave de Gemini configurada no es válida.";
  }
  if (message) return message;
  return undefined;
}

function sendError(response: Response, error: unknown): void {
  if (error instanceof HttpError) {
    response.status(error.status).json({error: error.message});
    return;
  }
  const grpcCode = (error as {code?: number})?.code;
  if (grpcCode === 5) {
    console.error("Firestore database not found:", firestoreDatabaseId, error);
    response.status(500).json({
      error: "No se pudo acceder a la base de datos de la app.",
    });
    return;
  }
  const geminiMessage = geminiErrorMessage(error);
  if (geminiMessage) {
    console.error("Gemini API error:", error);
    response.status(502).json({error: geminiMessage});
    return;
  }
  console.error("Unhandled createLiveToken error:", error);
  response.status(500).json({error: "No se pudo completar la solicitud."});
}

function cleanText(value: unknown): string {
  return typeof value === "string" ? value.trim() : "";
}

function profilePrompt(
  profile: Record<string, unknown>,
  previous?: Record<string, unknown>,
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
        `Fortalezas previas: ${asStringList((previous.report as Record<string, unknown> | undefined)?.strengths).join("; ")}`,
        `Áreas a mejorar: ${asStringList((previous.report as Record<string, unknown> | undefined)?.improvements).join("; ")}`,
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
      const {userRef, profile} = await readUserProfile(uid);

      const sourceLoopId = cleanText(request.body?.sourceLoopId);
      let previous: Record<string, unknown> | undefined;
      if (sourceLoopId) {
        previous = (
          await userRef.collection("loops").doc(sourceLoopId).get()
        ).data();
        if (!previous || previous.status !== "completed") {
          throw new HttpError(404, "No se encontró la práctica anterior.");
        }
      }

      const prompt = profilePrompt(profile, previous);
      const ai = geminiLiveClient(geminiApiKey.value());
      const now = Date.now();
      console.info("Creating Gemini live token for uid:", uid);
      const token = await ai.authTokens.create({
        config: {
          uses: 1,
          expireTime: new Date(now + 30 * 60 * 1000).toISOString(),
          newSessionExpireTime: new Date(now + 5 * 60 * 1000).toISOString(),
          httpOptions: {apiVersion: "v1alpha"},
        },
      });
      const tokenName = resolveGeminiTokenName(token);
      if (!tokenName) {
        console.error("Gemini token response missing name:", token);
        throw new HttpError(502, "Gemini no devolvió un token de sesión válido.");
      }

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

      console.info("Live token created for uid:", uid, "loop:", loopRef.id);
      response.json({
        token: tokenName,
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

      const {userRef} = await readUserProfile(uid);
      const loopRef = userRef.collection("loops").doc(loopId);
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
  const ai = geminiReportClient(geminiApiKey.value());
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
