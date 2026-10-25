#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
docker compose -f "$ROOT/lab/docker-compose.yml" down
echo "Metasploitable2 остановлен."
