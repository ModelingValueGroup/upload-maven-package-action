#!/bin/bash
set -euo pipefail

if [[ "$INPUT_TRACE" == "true" ]]; then
    set -x
fi

# this action repo exists on the client machine in:
#    /home/runner/work/_actions/ModelingValueGroup/upload-maven-package-action/<branch>

ls -l ../_actions/ModelingValueGroup/upload-maven-package-action/*
set

. ../_actions/ModelingValueGroup/upload-maven-package-action/*/functions.sh

main \
  "$INPUT_TOKEN" \
  "$INPUT_FILE"  \
  "$INPUT_GAVE"  \
  "$INPUT_POM"
