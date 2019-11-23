#!/bin/bash
set -e
set -o pipefail

ls -la /
pwd
. /functions.sh

main \
  "$GITHUB_REPOSITORY" \
  "$INPUT_TOKEN" \
  "$INPUT_FILE" \
  "$INPUT_GAVE" \
  "$INPUT_POM"
