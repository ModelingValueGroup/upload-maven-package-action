#!/bin/bash
set -e
set -o pipefail

###################################################
export      token="$1"; shift
export tokenOwner="$1"; shift
export       file="$1"; shift
export       gave="$1"; shift
export  repoOwner="$1"; shift
export   repoName="$1"; shift
###################################################
export packageUrl="https://maven.pkg.github.com/$repoOwner/$repoName"
###################################################

if [[ ! -f "$file" ]]; then
  echo "PROBLEM: file not found: $file"
  exit 99
fi
if ! which mvn &>/dev/null; then
  echo "PROBLEM: mvn not installed"
  exit 99
fi
if ! which xmlstarlet &>/dev/null; then
  echo "PROBLEM: xmlstarlet not installed"
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
  if [[ -f pom.xml ]]; then
    printf "%s:%s:%s:%s" \
      "$(xmlstarlet sel -t -v /_:project/_:groupId    <pom.xml)" \
      "$(xmlstarlet sel -t -v /_:project/_:artifactId <pom.xml)" \
      "$(xmlstarlet sel -t -v /_:project/_:version    <pom.xml)" \
      "$(xmlstarlet sel -t -v /_:project/_:packaging  <pom.xml)"
  fi
}
gave2vars() {
  local gave="$1"; shift

  if [[ $gave == "" ]]; then
    gave="$(extractGaveFromPom)"
  fi
  export g a v e
  IFS=: read g a v e <<<"$gave"
}

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
set
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

gave2vars "$gave"
generateSettings > settings.xml
if [[ -f pom.xml ]]; then
  mv pom.xml pom.xml-saved # move it out of the way, we have all the info extracted.
fi
mvn \
  -X \
  -B \
  -s settings.xml \
  deploy:deploy-file \
       -DgroupId="$g" \
    -DartifactId="$a" \
       -Dversion="$v" \
     -Dpackaging="$e" \
  -DrepositoryId="github" \
          -Dfile="$file" \
           -Durl="$packageUrl"
