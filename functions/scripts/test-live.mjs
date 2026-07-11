import {GoogleGenAI, Modality} from "@google/genai";

const apiKey = process.env.GEMINI_API_KEY;
if (!apiKey) {
  console.error("Missing GEMINI_API_KEY");
  process.exit(1);
}

const liveConfig = {
  responseModalities: [Modality.AUDIO],
};

async function waitForSetup(label, timeoutMs = 8000) {
  let setupDone = false;
  let closeReason = "";
  const ai = new GoogleGenAI({apiKey, apiVersion: "v1alpha"});
  const session = await ai.live.connect({
    model: "gemini-2.5-flash-native-audio-preview-12-2025",
    config: liveConfig,
    callbacks: {
      onopen: () => console.log(`${label}: open`),
      onmessage: (message) => {
        if (message.setupComplete) setupDone = true;
        console.log(`${label}: message`, JSON.stringify(message).slice(0, 240));
      },
      onerror: (error) => console.error(`${label}: error`, error),
      onclose: (event) => {
        closeReason = event.reason || "(no reason)";
        console.log(`${label}: close`, closeReason);
      },
    },
  });
  await new Promise((resolve) => setTimeout(resolve, timeoutMs));
  session.close();
  return {setupDone, closeReason};
}

async function waitForEphemeralSetup(label, timeoutMs = 8000) {
  let setupDone = false;
  let closeReason = "";
  const issuer = new GoogleGenAI({apiKey, apiVersion: "v1alpha"});
  const now = Date.now();
  const token = await issuer.authTokens.create({
    config: {
      uses: 1,
      expireTime: new Date(now + 30 * 60 * 1000).toISOString(),
      newSessionExpireTime: new Date(now + 5 * 60 * 1000).toISOString(),
      httpOptions: {apiVersion: "v1alpha"},
    },
  });
  console.log(`${label}: token`, token.name?.slice(0, 40));

  const ai = new GoogleGenAI({apiKey: token.name, apiVersion: "v1alpha"});
  const session = await ai.live.connect({
    model: "gemini-2.5-flash-native-audio-preview-12-2025",
    config: liveConfig,
    callbacks: {
      onopen: () => console.log(`${label}: open`),
      onmessage: (message) => {
        if (message.setupComplete) setupDone = true;
        console.log(`${label}: message`, JSON.stringify(message).slice(0, 240));
      },
      onerror: (error) => console.error(`${label}: error`, error),
      onclose: (event) => {
        closeReason = event.reason || "(no reason)";
        console.log(`${label}: close`, closeReason);
      },
    },
  });
  await new Promise((resolve) => setTimeout(resolve, timeoutMs));
  session.close();
  return {setupDone, closeReason};
}

const direct = await waitForSetup("direct");
console.log("direct result", direct);

const ephemeral = await waitForEphemeralSetup("ephemeral");
console.log("ephemeral result", ephemeral);
