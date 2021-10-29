#!/usr/bin/env bash

readonly T_PATH='/wp-content/uploads/'
readonly T_RESPONSE='Index of'
readonly SCHEME='http'
readonly PORT=80
readonly SCAN_W=1500
readonly SCAN_COUNT=10000
readonly CHECK_W=32

log() { echo $(date +%H:%M:%S) "$@" 1>&2; }

http_open() {
    log 'Start'
    nmap -n -Pn -T4 -iR $SCAN_COUNT -p $PORT \
        --host-timeout 1s --min-rate $SCAN_W --max-retries 1 \
        --open -oG - 2>/dev/null \
        | awk '/\/open\//{print $2}'
    log 'Got ips'
}

check() {
    local ip="$1"
    curl -sA 'Mozilla/5.0' "${SCHEME}://${ip}${T_PATH}" \
        | fgrep "${T_RESPONSE}" >/dev/null
}

download() {
    local ip="$1"
    wget -q -e robots=off -r -np -nd \
        -A jpg,png,gif,jpeg -P "out/$ip/" "${SCHEME}://${ip}${T_PATH}"
}

export -f check
export -f download

http_open | xargs -P $CHECK_W -I {} bash -c 'check && echo {} && download'
