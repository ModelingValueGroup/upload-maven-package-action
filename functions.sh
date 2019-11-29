#!/bin/bash
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
## (C) Copyright 2018-2019 Modeling Value Group B.V. (http://modelingvalue.org)                                        ~
##                                                                                                                     ~
## Licensed under the GNU Lesser General Public License v3.0 (the 'License'). You may not use this file except in      ~
## compliance with the License. You may obtain a copy of the License at: https://choosealicense.com/licenses/lgpl-3.0  ~
## Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on ~
## an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the  ~
## specific language governing permissions and limitations under the License.                                          ~
##                                                                                                                     ~
## Maintainers:                                                                                                        ~
##     Wim Bast, Carel Bast, Tom Brus                                                                                  ~
## Contributors:                                                                                                       ~
##     Arjan Kok, Ronald Krijgsheld                                                                                    ~
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

########################################################################################
########################################################################################
includeBuildTools() {
  local   token="$1"; shift
  local version="$1"; shift

  local buildToolsUrl="https://maven.pkg.github.com/ModelingValueGroup/buildTools/com.modelingvalue.buildTools/$version/buildTools-$version.jar"

  curl -s -H "Authorization: bearer $token" -L "$buildToolsUrl" -o buildTools-tmp.jar
  . <(java -jar buildTools-tmp.jar)
  rm buildTools-tmp.jar
}
main() (
    local token="$1"; shift
    local  file="$1"; shift
    local  gave="$1"; shift
    local   pom="$1"; shift

    includeBuildTools "$token" "1.0.30"

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

    # ## do the actual upload
    uploadArtifact "$token" "$gave" "$pom" "$file"
)
