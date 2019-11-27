#!/bin/bash
set -euo pipefail

if [[ "$INPUT_TRACE" == "true" ]]; then
    set -x
fi

echo "pwd=$PWD"
ls -la .
ls -la ..
exit


. /functions.sh

main \
  "$INPUT_TOKEN" \
  "$INPUT_FILE"  \
  "$INPUT_GAVE"  \
  "$INPUT_POM"
