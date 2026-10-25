#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COMPOSE_FILE="$ROOT/lab/docker-compose.yml"

if docker ps --format '{{.Names}}' | grep -qx metasploitable2; then
  echo "Metasploitable2 уже запущен (container: metasploitable2)."
  exit 0
fi

echo "Запуск Metasploitable 2 (Docker, host network)..."
docker compose -f "$COMPOSE_FILE" up -d

echo "Ожидание служб (~25 с)..."
sleep 25

if docker ps --format '{{.Names}}' | grep -qx metasploitable2; then
  echo "OK. Сканируйте цель: 127.0.0.1"
  echo "Логин в VM: docker exec -it metasploitable2 bash  (msfadmin / msfadmin)"
else
  echo "Ошибка: контейнер не поднялся. Логи: docker logs metasploitable2"
  exit 1
fi
