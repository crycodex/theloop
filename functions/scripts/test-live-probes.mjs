import {GoogleGenAI, MediaResolution, Modality} from "@google/genai";

const apiKey = process.env.GEMINI_API_KEY;
if (!apiKey) process.exit(1);

async function probe(label, config) {
  let setupDone = false;
  let closeReason = "";
  const ai = new GoogleGenAI({apiKey});
  const session = await ai.live.connect({
    model: "gemini-2.5-flash-native-audio-preview-12-2025",
    config,
    callbacks: {
      onmessage: (message) => {
        if (message.setupComplete) setupDone = true;
      },
      onclose: (event) => {
        closeReason = event.reason || "(no reason)";
      },
    },
  });
  await new Promise((resolve) => setTimeout(resolve, 3000));
  session.close();
  console.log(JSON.stringify({label, setupDone, closeReason}));
}

const probes = [
  ["minimal", {responseModalities: [Modality.AUDIO]}],
  ["media", {
    responseModalities: [Modality.AUDIO],
    mediaResolution: MediaResolution.MEDIA_RESOLUTION_MEDIUM,
  }],
  ["translate-en", {
    responseModalities: [Modality.AUDIO],
    translationConfig: {targetLanguageCode: "en"},
  }],
  ["translate-es", {
    responseModalities: [Modality.AUDIO],
    translationConfig: {targetLanguageCode: "es"},
  }],
  ["compression", {
    responseModalities: [Modality.AUDIO],
    contextWindowCompression: {
      triggerTokens: "0",
      slidingWindow: {targetTokens: "0"},
    },
  }],
  ["user-sample", {
    responseModalities: [Modality.AUDIO],
    mediaResolution: MediaResolution.MEDIA_RESOLUTION_MEDIUM,
    contextWindowCompression: {
      triggerTokens: "0",
      slidingWindow: {targetTokens: "0"},
    },
    translationConfig: {targetLanguageCode: "en"},
  }],
];

for (const [label, config] of probes) {
  await probe(label, config);
}
