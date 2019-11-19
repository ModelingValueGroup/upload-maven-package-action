#!/bin/bash
set -e
set -o pipefail

###################################################
export      token="$1"; shift
export tokenOwner="$1"; shift
export       file="$1"; shift
export  repoOwner="$1"; shift
export   repoName="$1"; shift
export       gave="$1"; shift
export        pom="$1"; shift
###################################################
export packageUrl="https://maven.pkg.github.com/$repoOwner/$repoName"
###################################################

if ! which mvn &>/dev/null; then
  echo "PROBLEM: mvn not installed"
  exit 99
fi
if ! which xmlstarlet &>/dev/null; then
  echo "PROBLEM: xmlstarlet not installed"
  exit 99
fi
if [[ ! -f "$file" ]]; then
  echo "PROBLEM: file not found: $file"
  exit 99
fi
if [[ $pom != "" && ! -f "$pom" ]]; then
  echo "PROBLEM: pom file not found: $pom"
  exit 99
fi

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
        <username>$tokenOwner</username>
        <password>$token</password>
      </server>
    </servers>
  </settings>
EOF
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
gave2vars() {
  local gave="$1"; shift
  local file="$1"; shift
  local  pom="$1"; shift

  if [[ $gave == "" ]]; then
    gave="$(extractGaveFromPom "$pom")"
  fi
  export g a v e
  IFS=: read g a v e <<<"$gave"
  if [[ $e == "" ]]; then
    e="${file##*.}"
  fi
}

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
set
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

if [[ $pom == "" && -f pom.xml ]]; then
  pom=pom.xml
fi
gave2vars "$gave" "$file" "$pom"
generateSettings > settings.xml
#if [[ -f $pom ]]; then
#  mv $pom $pom-saved # move it out of the way, we have all the info extracted.
#fi
mvn \
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
           -Durl="$packageUrl"
