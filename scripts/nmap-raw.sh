#!/usr/bin/env bash
# Raw scans (SYN/FIN/Xmas/UDP) via Docker when local nmap is not root-capable.
set -euo pipefail

SCANS_DIR="$(cd "$(dirname "$0")/../scans" && pwd)"
exec docker run --rm --net=host --cap-add=NET_RAW --cap-add=NET_ADMIN \
  -v "$SCANS_DIR:/scans" instrumentisto/nmap "$@"
