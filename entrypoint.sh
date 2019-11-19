#!/bin/bash
set -e
set -o pipefail

########################################################################################
export packageUrl="https://maven.pkg.github.com/$GITHUB_REPOSITORY"
########################################################################################
main() {
  checkArgs
  if [[ $INPUT_POM == "" && -f pom.xml ]]; then
    INPUT_POM=pom.xml
  fi
  gave2vars "$INPUT_GAVE" "$INPUT_FILE" "$INPUT_POM"
  generateSettings > settings.xml

  mvn \
    -B \
    -s settings.xml \
    deploy:deploy-file \
         -DgroupId="$g" \
      -DartifactId="$a" \
         -Dversion="$v" \
       -Dpackaging="$e" \
    -DrepositoryId="github" \
            -Dfile="$INPUT_FILE" \
         -DpomFile="$INPUT_POM" \
             -Durl="$packageUrl"
}
checkArgs() {
  if ! command -v mvn &>/dev/null; then
    echo "PROBLEM: mvn not installed"
    exit 99
  fi
  if ! command -v xmlstarlet &>/dev/null; then
    echo "PROBLEM: xmlstarlet not installed"
    exit 99
  fi
  if [[ ! -f "$INPUT_FILE" ]]; then
    echo "PROBLEM: file not found: $INPUT_FILE"
    exit 99
  fi
  if [[ $INPUT_POM != "" && ! -f "$INPUT_POM" ]]; then
    echo "PROBLEM: pom file not found: $INPUT_POM"
    exit 99
  fi
}
generateSettings() {
  cat  <<EOF
  <settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <activeProfiles>
      <activeProfile>github</activeProfile>
    </activeProfiles>

    <profiles>
      <profile>
        <id>github</id>
        <repositories>
          <repository>
            <id>central</id>
            <url>https://repo1.maven.org/maven2</url>
            <releases><enabled>true</enabled></releases>
            <snapshots><enabled>false</enabled></snapshots>
          </repository>
          <repository>
            <id>github</id>
            <name>GitHub Apache Maven Packages</name>
            <url>$packageUrl</url>
          </repository>
        </repositories>
      </profile>
    </profiles>

    <servers>
      <server>
        <id>github</id>
        <username>$INPUT_TOKENOWNER</username>
        <password>$INPUT_TOKEN</password>
      </server>
    </servers>
  </settings>
EOF
}
gave2vars() {
  local gave="$1"; shift
  local file="$1"; shift
  local  pom="$1"; shift

  if [[ $gave == "" ]]; then
    gave="$(extractGaveFromPom "$pom")"
  fi
  export g a v e
  IFS=: read -r g a v e <<<"$gave"
  if [[ $e == "" ]]; then
    e="${file##*.}"
  fi
}
extractGaveFromPom() {
  local  pom="$1"; shift

  if [[ -f "$pom" ]]; then
    printf "%s:%s:%s:%s" \
      "$(xmlstarlet sel -t -v /_:project/_:groupId    <"$pom")" \
      "$(xmlstarlet sel -t -v /_:project/_:artifactId <"$pom")" \
      "$(xmlstarlet sel -t -v /_:project/_:version    <"$pom")" \
      "$(xmlstarlet sel -t -v /_:project/_:packaging  <"$pom")"
  fi
}
########################################################################################
main
########################################################################################
