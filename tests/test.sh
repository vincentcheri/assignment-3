#!/usr/bin/env bash

set -uo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
APP="$ROOT_DIR/app/app.sh"
passed=0
failed=0
output=''
actual_status=0

run_app() {
    if output=$("$APP" "$@" 2>&1); then
        actual_status=0
    else
        actual_status=$?
    fi
}

check_status() {
    local name=$1
    local expected=$2
    shift 2

    run_app "$@"
    if [[ $actual_status -eq $expected ]]; then
        printf 'PASS: %s\n' "$name"
        ((passed += 1))
    else
        printf 'FAIL: %s (expected status %s, got %s)\n' "$name" "$expected" "$actual_status"
        printf '  output: %s\n' "$output"
        ((failed += 1))
    fi
}

check_output_contains() {
    local name=$1
    local expected=$2
    shift 2

    run_app "$@"
    if [[ $actual_status -eq 0 && $output == *"$expected"* ]]; then
        printf 'PASS: %s\n' "$name"
        ((passed += 1))
    else
        printf "FAIL: %s (status %s; expected output containing '%s')\n" "$name" "$actual_status" "$expected"
        printf '  output: %s\n' "$output"
        ((failed += 1))
    fi
}

check_output_contains 'help displays usage' 'Usage:' help
check_output_contains 'system-info displays operating system' 'Operating system:' system-info
check_status 'invalid command returns status 2' 2 unknown-command
check_status 'missing host returns status 2' 2 check-host
check_output_contains 'localhost resolves' 'Host resolves: localhost' check-host localhost
check_status 'missing port returns status 2' 2 check-port localhost
check_status 'non-numeric port returns status 2' 2 check-port localhost abc
check_status 'port zero returns status 2' 2 check-port localhost 0
check_status 'port above 65535 returns status 2' 2 check-port localhost 65536

printf '\n%d passed, %d failed.\n' "$passed" "$failed"
[[ $failed -eq 0 ]]