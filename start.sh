#!/bin/bash
set -e
BASE="$(cd "$(dirname "$0")" && pwd)"
PID_DIR="$BASE/run"
LOG_DIR="$BASE/logs"
mkdir -p "$PID_DIR" "$LOG_DIR"

start_server() {
    local name="$1"
    local port="$2"
    local dir="$3"
    local pidfile="$PID_DIR/${name}.pid"
    if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
        echo "$name already running on port $port"
        return
    fi
    python3 -m http.server "$port" --directory "$dir" >"$LOG_DIR/${name}.log" 2>&1 &
    echo $! > "$pidfile"
    echo "Started $name on port $port (PID $(cat "$pidfile"))"
}

stop_all() {
    for pidfile in "$PID_DIR"/*.pid; do
        [ -f "$pidfile" ] || continue
        kill "$(cat "$pidfile")" 2>/dev/null || true
        rm -f "$pidfile"
    done
    if [ -f "$PID_DIR/haproxy.pid" ]; then
        kill "$(cat "$PID_DIR/haproxy.pid")" 2>/dev/null || true
        rm -f "$PID_DIR/haproxy.pid"
    fi
    echo "Stopped all services"
}

start_haproxy() {
    local pidfile="$PID_DIR/haproxy.pid"
    if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
        echo "HAProxy already running"
        return
    fi
    "$BASE/bin/haproxy" -f "$BASE/config/haproxy.cfg" -p "$pidfile"
    echo "Started HAProxy (PID $(cat "$pidfile"))"
}

case "${1:-start}" in
    start)
        start_server task1-s1 8888 "$BASE/servers/task1-s1"
        start_server task1-s2 9999 "$BASE/servers/task1-s2"
        start_server task2-s1 8081 "$BASE/servers/task2-s1"
        start_server task2-s2 8082 "$BASE/servers/task2-s2"
        start_server task2-s3 8083 "$BASE/servers/task2-s3"
        sleep 1
        start_haproxy
        ;;
    stop)
        stop_all
        ;;
    restart)
        stop_all
        sleep 1
        "$0" start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
        ;;
esac
