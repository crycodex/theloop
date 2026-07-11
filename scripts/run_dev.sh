#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f env.json ]]; then
  echo "Falta env.json. Copia env.example.json y agrega tu GEMINI_API_KEY."
  exit 1
fi

flutter run --dart-define-from-file=env.json "$@"
