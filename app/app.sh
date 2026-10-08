#!/usr/bin/env bash

set -o nounset

usage() {
    cat <<'USAGE'
Usage:
  app.sh system-info
  app.sh check-host <host>
  app.sh check-port <host> <port>
  app.sh help
USAGE
}

system_info() {
    printf 'Operating system: %s\n' "$(uname -s)"
    printf 'Kernel: %s\n' "$(uname -r)"
    printf 'Architecture: %s\n' "$(uname -m)"
    printf 'Hostname: %s\n' "$(hostname)"
}

check_host() {
    local host=$1

    if ! getent hosts "$host" >/dev/null 2>&1; then
        printf 'Unable to resolve host: %s\n' "$host" >&2
        return 1
    fi

    printf 'Host resolves: %s\n' "$host"
}

check_port() {
    local host=$1
    local port=$2
    local normalized_port=$port

    if [[ ! $port =~ ^[0-9]+$ ]]; then
        printf 'Port must be a number between 1 and 65535.\n' >&2
        return 2
    fi

    while [[ $normalized_port == 0* && ${#normalized_port} -gt 1 ]]; do
        normalized_port=${normalized_port#0}
    done

    if [[ ${#normalized_port} -gt 5 ]] || (( normalized_port < 1 || normalized_port > 65535 )); then
        printf 'Port must be between 1 and 65535.\n' >&2
        return 2
    fi

    if ! getent hosts "$host" >/dev/null 2>&1; then
        printf 'Unable to resolve host: %s\n' "$host" >&2
        return 1
    fi

    if timeout 3 bash -c 'exec 3<>"/dev/tcp/$1/$2"' _ "$host" "$normalized_port" 2>/dev/null; then
        printf 'TCP connection succeeded: %s:%s\n' "$host" "$normalized_port"
    else
        printf 'TCP connection failed: %s:%s\n' "$host" "$normalized_port" >&2
        return 1
    fi
}

case "${1:-}" in
    system-info)
        if [[ $# -ne 1 ]]; then
            usage >&2
            exit 2
        fi
        system_info
        ;;
    check-host)
        if [[ $# -ne 2 || -z ${2:-} ]]; then
            usage >&2
            exit 2
        fi
        check_host "$2"
        ;;
    check-port)
        if [[ $# -ne 3 || -z ${2:-} || -z ${3:-} ]]; then
            usage >&2
            exit 2
        fi
        check_port "$2" "$3"
        ;;
    help)
        if [[ $# -ne 1 ]]; then
            usage >&2
            exit 2
        fi
        usage
        ;;
    *)
        usage >&2
        exit 2
        ;;
esac