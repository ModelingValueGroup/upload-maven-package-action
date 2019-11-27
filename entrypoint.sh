#!/bin/bash
set -euo pipefail

if [[ "$INPUT_TRACE" == "true" ]]; then
    set -x
fi

. "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

main \
  "$INPUT_TOKEN" \
  "$INPUT_FILE"  \
  "$INPUT_GAVE"  \
  "$INPUT_POM"
