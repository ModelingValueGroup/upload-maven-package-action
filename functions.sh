#!/bin/bash

########################################################################################
########################################################################################
main() (
  local githubRepos="$1"; shift
  local       token="$1"; shift
  local        file="$1"; shift
  local        gave="$1"; shift
  local         pom="$1"; shift

  includeBuildTools "$token" "1.0.5"

  local githubPackageUrl="https://maven.pkg.github.com/$githubRepos"

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

  local g a v e
  gave2vars "$file" "$pom" "$gave"

  if [[ "${DRY:-}" == "" ]] && listPackageVersions "$g" "$a" "$token" | grep -Fx "$v" &> /dev/null; then
    echo "::error::version $v is already published as a package. Existing versions: [$(listPackageVersions "$g" "$a" "$token" | tr '\n' ',' | sed 's/,/, /')]"
    exit 99
  fi

  generateMavenSettings "$token"> settings.xml

  ${DRY:-} mvn \
    -B \
    -s settings.xml \
    deploy:deploy-file \
         -DgroupId="$g" \
      -DartifactId="$a" \
         -Dversion="$v" \
       -Dpackaging="$e" \
    -DrepositoryId="github" \
            -Dfile="$file" \
         -DpomFile="$pom" \
             -Durl="$githubPackageUrl"

)
includeBuildTools() {
  local   token="$1"; shift
  local version="$1"; shift

  local buildToolsUrl="https://maven.pkg.github.com/ModelingValueGroup/buildTools/com.modelingvalue.buildTools/$version/buildTools-$version.sh"

  # shellcheck disable=SC1090
  . <(curl -s -H "Authorization: bearer $token" -L "$buildToolsUrl" -o - )
}
