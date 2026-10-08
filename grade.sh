#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bash "$ROOT_DIR/scripts/lint.sh"
bash "$ROOT_DIR/tests/test.sh"
bash "$ROOT_DIR/scripts/build.sh"