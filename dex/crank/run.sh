#!/bin/sh

set -eu

usage() {
    echo "Usage: $0 /absolute/path/to/payer-keypair.json" >&2
}

require_env() {
    variable_name=$1
    variable_value=$2
    if [ -z "$variable_value" ]; then
        echo "Missing required environment variable: $variable_name" >&2
        exit 1
    fi
}

stop_children() {
    if [ -n "${child_pids:-}" ]; then
        # Word splitting is intentional: child_pids is a space-separated PID list.
        kill $child_pids 2>/dev/null || true
        wait $child_pids 2>/dev/null || true
    fi
}

if [ "$#" -ne 1 ]; then
    usage
    exit 1
fi

payer_path=$1
markets_file=${MARKETS_FILE:-markets.txt}
log_dir=${LOG_DIR:-logs}
num_workers=${NUM_WORKERS:-1}
events_per_worker=${EVENTS_PER_WORKER:-1}
idle_sleep_seconds=${IDLE_SLEEP_SECONDS:-30}
start_delay_seconds=${START_DELAY_SECONDS:-1}

require_env RPC_URL "${RPC_URL:-}"
require_env DEX_PROGRAM_ID "${DEX_PROGRAM_ID:-}"
require_env COIN_WALLET "${COIN_WALLET:-}"
require_env PC_WALLET "${PC_WALLET:-}"

if [ ! -f "$payer_path" ]; then
    echo "Payer keypair not found: $payer_path" >&2
    exit 1
fi

if [ ! -f "$markets_file" ]; then
    echo "Markets file not found: $markets_file" >&2
    echo "Copy markets.example.txt to markets.txt and add market public keys." >&2
    exit 1
fi

mkdir -p "$log_dir"
child_pids=""
market_count=0

trap stop_children EXIT HUP INT TERM

while IFS= read -r market || [ -n "$market" ]; do
    case "$market" in
        ""|\#*) continue ;;
    esac

    log_path="$log_dir/$market.log"
    echo "Starting crank for market $market; log: $log_path"

    cargo run -- \
        "$RPC_URL" consume-events \
        --dex-program-id "$DEX_PROGRAM_ID" \
        --payer "$payer_path" \
        --coin-wallet "$COIN_WALLET" \
        --pc-wallet "$PC_WALLET" \
        --market "$market" \
        --num-workers "$num_workers" \
        --events-per-worker "$events_per_worker" \
        --idle-sleep-seconds "$idle_sleep_seconds" \
        --log-directory "$log_path" &

    child_pids="$child_pids $!"
    market_count=$((market_count + 1))
    sleep "$start_delay_seconds"
done < "$markets_file"

if [ "$market_count" -eq 0 ]; then
    echo "No markets found in $markets_file" >&2
    exit 1
fi

echo "Started $market_count crank process(es). Press Ctrl-C to stop them."
wait
