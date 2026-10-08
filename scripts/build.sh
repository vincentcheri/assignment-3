#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

docker build -t devops-tool "$ROOT_DIR"
docker run --rm devops-tool help
docker run --rm devops-tool system-info

if docker run --rm devops-tool invalid-command >/dev/null 2>&1; then
    printf 'Docker smoke test failed: invalid command unexpectedly succeeded.\n' >&2
    exit 1
else
    status=$?
    if [[ $status -ne 2 ]]; then
        printf 'Docker smoke test failed: invalid command exited with status %s, expected 2.\n' "$status" >&2
        exit 1
    fi
fi

printf 'Docker smoke tests passed.\n'