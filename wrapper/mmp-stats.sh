#!/usr/bin/env bash
GPU_COUNT=$1
LOG_FILE=$2
cd `dirname $0`
[ -r mmp-external.conf ] && . mmp-external.conf

get_miner_stats() {
    DATA=$(curl -s http://127.0.0.1:8888)
    
    stats=
    local hash=$(jq '.hashrate' <<< "$DATA")
    # A/R shares by pool
    local acc=$(jq '.accepted' <<< "$DATA")
    # local inv=$(get_miner_shares_inv)
    local rej=$(jq '.rejected' <<< "$DATA")

    stats=$(jq -nc \
            --argjson hash "$(echo $hash | tr " " "\n" | jq -cs '.')" \
            --arg busid "cpu" \
            --arg units "khs" \
            --arg ac "$acc" --arg inv "0" --arg rj "$rej" \
            --arg miner_version "$EXTERNAL_VERSION" \
            --arg miner_name "$EXTERNAL_NAME" \
        '{busid: [$busid], $hash, $units, air: [$ac, $inv, $rj], miner_name: $miner_name, miner_version: $miner_version}')
    echo $stats
}
get_miner_stats