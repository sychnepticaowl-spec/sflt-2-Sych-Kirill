#!/usr/bin/env bash
# Metasploitable 2 — SYN / FIN / Xmas / UDP (задание 2)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-127.0.0.1}"
PORTS="${2:-21,22,23,25,80,139,445,3306,5432,6667}"
OUT_DIR="$ROOT/scans"
NMAP_RAW="$ROOT/scripts/nmap-raw.sh"

mkdir -p "$OUT_DIR"
chmod +x "$NMAP_RAW"

echo "Target: $TARGET (raw scans via Docker nmap)"

"$NMAP_RAW" -sS -p "$PORTS" -oN "/scans/task2-syn.txt" "$TARGET"
"$NMAP_RAW" -sF -p "$PORTS" -oN "/scans/task2-fin.txt" "$TARGET"
"$NMAP_RAW" -sX -p "$PORTS" -oN "/scans/task2-xmas.txt" "$TARGET"
"$NMAP_RAW" -sU --top-ports 20 -oN "/scans/task2-udp.txt" "$TARGET"

echo "Logs: $OUT_DIR/task2-*.txt"
echo "PCAP (если уже сняты): $ROOT/pcap/task2-*.pcap"
