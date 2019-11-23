#!/bin/bash

########################################################################################
########################################################################################
main() (
  local githubRepos="$1"; shift
  local       token="$1"; shift
  local        file="$1"; shift
  local        gave="$1"; shift
  local         pom="$1"; shift

  includeBuildTools "$token" "1.0.1"

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

  gave2vars "$file" "$pom" "$gave"

  if listPackageVersions "$g" "$a" "$token" | fgrep -Fxq "$v"; then
    echo "::error::version $v is already published as a package. Existing versions: [$(listPackageVersions "$g" "$a" "$token")]"
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

  . <(curl -s -H "Authorization: bearer $token" -L "https://maven.pkg.github.com/ModelingValueGroup/buildTools/com.modelingvalue.buildTools/$version/buildTools-$version.sh" -o - \
    |sed 's/fi#/fi #/') #TODO remove this

export  GITHUB_REPOSITORY=${githubRepos:-??} #TODO remove this
export GITHUB_PACKAGE_URL="https://maven.pkg.github.com/$GITHUB_REPOSITORY" #TODO remove this
export           USERNAME="${GITHUB_REPOSITORY/\/*}" #TODO remove this
export          REPOSNAME="${GITHUB_REPOSITORY/*\/}" #TODO remove this
}


# TODO remove the functions below:
downloadArtifactQuick() {
  local token="$1"; shift
  local     g="$1"; shift
  local     a="$1"; shift
  local     v="$1"; shift
  local     e="$1"; shift
  local   dir="$1"; shift

  curl -s -H "Authorization: bearer $token" -L "$GITHUB_PACKAGE_URL/$g.$a/$v/$a-$v.$e" -o "$dir/$a.$e"
}
downloadArtifact() {
  local token="$1"; shift
  local     g="$1"; shift
  local     a="$1"; shift
  local     v="$1"; shift
  local     e="$1"; shift
  local   dir="$1"; shift

  generateMavenSettings "$token" >settings.xml
  mvn \
    -B \
    -s settings.xml \
    org.apache.maven.plugins:maven-dependency-plugin:LATEST:get \
    -DrepositoryId="github" \
         -DgroupId="$g" \
      -DartifactId="$a" \
         -Dversion="$v" \
       -Dpackaging="$e" \
            -Ddest="$dir/$a.$e"
  rm settings.xml
}
generateMavenSettings() {
  local password="$1"; shift

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
            <url>$GITHUB_PACKAGE_URL</url>
          </repository>
        </repositories>
      </profile>
    </profiles>

    <servers>
      <server>
        <id>github</id>
        <username>$USERNAME</username>
        <password>$password</password>
      </server>
    </servers>
  </settings>
EOF
}
graphqlQuery() {
  local token="$1"; shift
  local query="$1"; shift

  curl -s -H "Authorization: bearer $token" -X POST -d '{"query":"'"$query"'"}' 'https://api.github.com/graphql'
}
latestPackageVersions() {
  listPackageVersions "$@" | tail -1
}
listPackageVersions() {
  local     g="$1"; shift
  local     a="$1"; shift
  local token="$1"; shift

  local query
  query="$(cat <<EOF | sed 's/"/\\"/g' | tr '\n\r' '  '
query {
    repository(owner:"$USERNAME", name:"$REPOSNAME"){
        registryPackages(name:"$g.$a",first:1) {
            nodes {
                versions(last:100) {
                    nodes {
                        version
                    }
                }
            }
        }
    }
}
EOF
)"
  graphqlQuery "$token" "$query" | jq -r '.data.repository.registryPackages.nodes[0].versions.nodes[].version'
}
gave2vars() {
  local file="$1"; shift
  local  pom="$1"; shift
  local gave="${1:-}"; shift || :

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
