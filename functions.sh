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
##     Wim Bast, Tom Brus, Ronald Krijgsheld                                                                           ~
## Contributors:                                                                                                       ~
##     Arjan Kok, Carel Bast                                                                                           ~
##~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

main() (
    local token="$1"; shift
    local  file="$1"; shift
    local  gave="$1"; shift
    local   pom="$1"; shift

    includeBuildTools "$token" "$buildToolsVersion"

    ### check arguments
    if [[ ! -f "$file" ]]; then
        echo "::error:: file not found: $file"
        exit 99
    fi

    ### determine pom file if it can be found...
    if [[ $pom != "" && ! -f "$pom" ]]; then
        echo "::error:: pom file not found: $pom"
        exit 99
    fi
    if [[ $pom == "" && -f pom.xml ]]; then
        pom=pom.xml
    fi

    export g a v e versionList
    gave2vars "$gave" "$pom" "$file"

    ### check if this versions already exists:
    if listPackageVersions "$token" "$GITHUB_REPOSITORY" "$g" "$a" "" | grep -Fx "$v" &> /dev/null; then
        versionList="[$(listPackageVersions "$token" "$GITHUB_REPOSITORY" "$g" "$a" "" | tr '\n' ',' | sed 's/,$//;s/,/, /g')]"
        echo "::error::version $v is already published as a package for artifact $a. Existing versions: $versionList"
        exit 99
    fi

    ### do the actual upload:
    uploadArtifactQuick "$token" "$g" "$a" "$v" "$pom" "$file"
)
