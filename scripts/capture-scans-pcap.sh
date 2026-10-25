#!/usr/bin/env bash
# Захват pcap на lo при nmap (задание 2, Wireshark)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-127.0.0.1}"
PORTS="${2:-21,22,80,3306,6667}"
PCAP="$ROOT/pcap"
NMAP_RAW="$ROOT/scripts/nmap-raw.sh"

mkdir -p "$PCAP"
chmod +x "$NMAP_RAW"

capture() {
  local mode=$1
  shift
  docker rm -f "cap-$mode" 2>/dev/null || true
  docker run -d --name "cap-$mode" --net=host --cap-add=NET_RAW --cap-add=NET_ADMIN \
    -v "$PCAP:/pcap" nicolaka/netshoot \
    tcpdump -i lo -s 0 -w "/pcap/task2-${mode}.pcap" "host $TARGET and (tcp or udp or icmp)"
  sleep 1
  "$NMAP_RAW" "$@" "$TARGET" >/dev/null
  sleep 1
  docker stop "cap-$mode" >/dev/null
  docker rm "cap-$mode" >/dev/null
}

capture syn -sS -p "$PORTS"
capture fin -sF -p "$PORTS"
capture xmas -sX -p "$PORTS"
capture udp -sU --top-ports 20

docker run --rm -v "$PCAP:/pcap" alpine chown 1000:1000 /pcap/task2-syn.pcap /pcap/task2-fin.pcap /pcap/task2-xmas.pcap /pcap/task2-udp.pcap 2>/dev/null || true
echo "Saved: $PCAP/task2-{syn,fin,xmas,udp}.pcap"
