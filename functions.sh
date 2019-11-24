#!/bin/bash

########################################################################################
########################################################################################
includeBuildTools() {
  local   token="$1"; shift
  local version="$1"; shift

  local buildToolsUrl="https://maven.pkg.github.com/ModelingValueGroup/buildTools/com.modelingvalue.buildTools/$version/buildTools-$version.sh"

  # shellcheck disable=SC1090
  . <(curl -s -H "Authorization: bearer $token" -L "$buildToolsUrl" -o - )
}
main() (
  local token="$1"; shift
  local  file="$1"; shift
  local  gave="$1"; shift
  local   pom="$1"; shift

  includeBuildTools "$token" "1.0.6"

  if ! command -v mvn &>/dev/null; then
    echo "::error:: mvn not installed"
    exit 99
  fi
  if ! command -v xmlstarlet &>/dev/null; then
    echo "::error:: xmlstarlet not installed"
    exit 99
  fi
  if [[ ! -f "$file" ]]; then
    echo "::error:: file not found: $file"
    exit 99
  fi
  if [[ $pom != "" && ! -f "$pom" ]]; then
    echo "::error:: pom file not found: $pom"
    exit 99
  fi
  if [[ $pom == "" && -f pom.xml ]]; then
    pom=pom.xml
  fi
  if [[ "${DRY:-}" == "" ]] && listPackageVersions "$token" "$GITHUB_REPOSITORY" "$gave" "$pom" | grep -Fx "$v" &> /dev/null; then
    echo "::error::version $v is already published as a package. Existing versions: [$(listPackageVersions "$token" "$GITHUB_REPOSITORY" "$gave" "$pom" | tr '\n' ',' | sed 's/,$//;s/,/, /g')]"
    exit 99
  fi

  uploadArtifact "$token" "$gave" "$pom" "$file"
)
