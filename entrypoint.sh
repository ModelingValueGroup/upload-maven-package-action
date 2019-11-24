#!/bin/bash
set -euo pipefail

ls -la /
pwd
. /functions.sh

main \
  "$GITHUB_REPOSITORY" \
  "$INPUT_TOKEN" \
  "$INPUT_FILE" \
  "$INPUT_GAVE" \
  "$INPUT_POM"
