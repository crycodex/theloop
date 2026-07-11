#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${GEMINI_API_KEY:-}" ]]; then
  echo "Exporta GEMINI_API_KEY antes de ejecutar este script."
  echo "Ejemplo: GEMINI_API_KEY='tu_clave' ./scripts/setup_gemini_secret.sh"
  exit 1
fi

printf '%s' "$GEMINI_API_KEY" | firebase functions:secrets:set GEMINI_API_KEY --project the-loop-d46af
