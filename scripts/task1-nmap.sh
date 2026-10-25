#!/usr/bin/env bash
# Metasploitable 2 — версии служб (задание 1)
set -euo pipefail

TARGET="${1:-127.0.0.1}"
OUT_DIR="$(dirname "$0")/../scans"

mkdir -p "$OUT_DIR"

echo "Target: $TARGET"
nmap -sV --reason -oN "$OUT_DIR/task1-sV.txt" "$TARGET"

echo "Result: $OUT_DIR/task1-sV.txt"
