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

echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
set
echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"

show() {
  local f="$1"; shift

  echo
  echo "@@@@@@@@@@@@@@@@@@@ BEGIN $f"
  sed 's/^/@@@/' "$f" || :
  echo "@@@@@@@@@@@@@@@@@@@ END   $f"
}

if [[ ! -f "$file" ]]; then
  echo "PROBLEM: file not found: $file"
  exit 99
fi

mkdir -p ~/.m2
cat > ~/.m2/settings.xml <<EOF
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
          <url>https://maven.pkg.github.com/$repoOwner/$repoName</url>
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

ls -ld ~
whoami
mvn --version
show "/usr/share/maven/conf/settings.xml"
show "/root/.m2/settings.xml"

show "/usr/share/apache-maven-3.6.1/conf/settings.xml"
show "/home/runner/.m2/settings.xml"


gave2vars() {
  local gave="$1"; shift

  export g a v e
  IFS=: read g a v e <<<"$gave"
}

gave2vars "$gave"
set -x
mvn -X -B \
  deploy:deploy-file \
  -DgroupId="$g" \
  -DartifactId="$a" \
  -Dversion="$v" \
  -Dpackaging="$e" \
  -DrepositoryId=github \
  -Dfile="$file" \
  -Durl="https://maven.pkg.github.com/$repoOwner/$repoName"
