/**
 * Sube los roadmaps predefinidos de scripts/roadmap_catalog/*.json a la
 * colección `roadmap_catalog` de Firestore (un documento por goalId).
 *
 * Requiere credenciales de admin del proyecto the-loop-d46af:
 *   1. Descarga una service account key desde Firebase Console
 *      (Project settings → Service accounts → Generate new private key).
 *   2. Ejecuta desde la raíz del repo (usa firebase-admin de functions/):
 *      GOOGLE_APPLICATION_CREDENTIALS=/ruta/sa.json node scripts/seed_roadmap_catalog.mjs
 *
 * El script es idempotente: reemplaza el documento completo de cada goal.
 */
import { readFileSync, readdirSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const require = createRequire(
  join(dirname(fileURLToPath(import.meta.url)), '../functions/index.js'),
);
const { initializeApp, applicationDefault } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');

// La app usa la base de datos con id 'default' (no la '(default)' implícita).
const DATABASE_ID = 'default';
const PROJECT_ID = 'the-loop-d46af';

const catalogDir = join(
  dirname(fileURLToPath(import.meta.url)),
  'roadmap_catalog',
);

const app = initializeApp({
  credential: applicationDefault(),
  projectId: PROJECT_ID,
});
const db = getFirestore(app, DATABASE_ID);

const files = readdirSync(catalogDir).filter((f) => f.endsWith('.json'));
if (files.length === 0) {
  console.error(`No hay JSONs en ${catalogDir}`);
  process.exit(1);
}

for (const file of files) {
  const raw = JSON.parse(readFileSync(join(catalogDir, file), 'utf8'));
  const { goalId, steps } = raw;
  if (!goalId || !Array.isArray(steps) || steps.length === 0) {
    console.error(`✗ ${file}: falta goalId o steps`);
    process.exitCode = 1;
    continue;
  }
  const stepIds = steps.map((s) => s.id);
  if (stepIds.some((id) => !id) || new Set(stepIds).size !== stepIds.length) {
    console.error(`✗ ${file}: ids de steps vacíos o duplicados`);
    process.exitCode = 1;
    continue;
  }
  await db.collection('roadmap_catalog').doc(goalId).set({
    ...raw,
    updatedAt: new Date().toISOString(),
  });
  console.log(`✓ roadmap_catalog/${goalId} (${steps.length} pasos) ← ${file}`);
}
