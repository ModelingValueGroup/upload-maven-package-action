#!/bin/bash
set -euo pipefail

. /functions.sh

main \
  "$INPUT_TOKEN" \
  "$INPUT_FILE" \
  "$INPUT_GAVE" \
  "$INPUT_POM"
