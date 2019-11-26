#!/bin/bash

########################################################################################
########################################################################################
includeBuildTools() {
  local   token="$1"; shift
  local version="$1"; shift

  local buildToolsUrl="https://maven.pkg.github.com/ModelingValueGroup/buildTools/com.modelingvalue.buildTools/$version/buildTools-$version.sh"

  curl -s -H "Authorization: bearer $token" -L "$buildToolsUrl" -o buildTools-tmp.sh
  . buildTools-tmp.sh
  rm buildTools-tmp.sh
}
main() (
  local token="$1"; shift
  local  file="$1"; shift
  local  gave="$1"; shift
  local   pom="$1"; shift

  includeBuildTools "$token" "1.0.25"

  ### check arguments
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

  ### check if this version is already uploaded
  export g a v e
  gave2vars "$gave" "$pom" "$file"
  if [[ "${DRY:-}" == "" ]] && listPackageVersions "$token" "$GITHUB_REPOSITORY" "$gave" "$pom" | grep -Fx "$v" &> /dev/null; then
    echo "::error::version $v is already published as a package. Existing versions: [$(listPackageVersions "$token" "$GITHUB_REPOSITORY" "$gave" "$pom" | tr '\n' ',' | sed 's/,$//;s/,/, /g')]"
    exit 99
  fi

  ### do the actual upload
  uploadArtifact "$token" "$gave" "$pom" "$file"
)
