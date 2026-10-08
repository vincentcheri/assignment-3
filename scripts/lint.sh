#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
required_files=(
    README.md
    app/app.sh
    scripts/lint.sh
    scripts/build.sh
    tests/test.sh
    .github/workflows/ci.yml
    Dockerfile
    compose.yaml
    .dockerignore
    grade.sh
)

for file in "${required_files[@]}"; do
    if [[ ! -f "$ROOT_DIR/$file" ]]; then
        printf 'Missing required file: %s\n' "$file" >&2
        exit 1
    fi
done

for script in "$ROOT_DIR/app/app.sh" "$ROOT_DIR/scripts/"*.sh "$ROOT_DIR/tests/"*.sh "$ROOT_DIR/grade.sh"; do
    bash -n "$script"
done

printf 'Lint passed: required files exist and Bash syntax is valid.\n'