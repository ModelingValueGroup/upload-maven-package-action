#!/bin/bash
set -e
set -o pipefail

. functions.sh

main \
  "$GITHUB_REPOSITORY" \
  "$INPUT_TOKEN" \
  "$INPUT_FILE" \
  "$INPUT_GAVE" \
  "$INPUT_POM"
