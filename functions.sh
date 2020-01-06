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

########################################################################################
########################################################################################
export sourcesExtra="-sources"
export javadocExtra="-javadoc"
########################################################################################
includeBuildTools() {
    local   token="$1"; shift
    local version="$1"; shift

    local buildToolsUrl="https://maven.pkg.github.com/ModelingValueGroup/buildTools/org.modelingvalue.buildTools/$version/buildTools-$version.jar"

    curl -s -H "Authorization: bearer $token" -L "$buildToolsUrl" -o buildTools-tmp.jar
    . <(java -jar buildTools-tmp.jar)
    rm buildTools-tmp.jar
}
getSourcesName() {
    local  file="$1"; shift

    printf "%s" "${file%.*}$sourcesExtra.${file##*.}"
}
getJavadocName() {
    local  file="$1"; shift

    printf "%s" "${file%.*}$javadocExtra.${file##*.}"
}
main() (
    local token="$1"; shift
    local  file="$1"; shift
    local  gave="$1"; shift
    local   pom="$1"; shift

    includeBuildTools "$token" "1.2.1"

    ### check arguments
    if [[ ! -f "$file" ]]; then
        echo "::error:: file not found: $file"
        exit 99
    fi
    local files=("$file")
    if [[ -f    "$(getSourcesName "$file")" ]]; then
        files+=("$(getSourcesName "$file")")
    fi
    if [[ -f    "$(getJavadocName "$file")" ]]; then
        files+=("$(getJavadocName "$file")")
    fi

    ### determine pom file if it can be found...
    if [[ $pom != "" && ! -f "$pom" ]]; then
        echo "::error:: pom file not found: $pom"
        exit 99
    fi
    if [[ $pom == "" && -f pom.xml ]]; then
        pom=pom.xml
    fi

    export g a v e
    gave2vars "$gave" "$pom" "$file"
    local gg="$g"
    local aa="$a"
    local vv="$v"
    local ee="$e"

    if [[ "${DRY:-}" == "" ]]; then # only do not do this when dry-testing, since the test packages are likely non-existent
        ### check if this versions is already uploaded:
        if listPackageVersions "$token" "$GITHUB_REPOSITORY" "$gg:$aa:$vv:$ee" "" | grep -Fx "$v" &> /dev/null; then
            local versionList
            versionList="[$(listPackageVersions "$token" "$GITHUB_REPOSITORY" "$gg:$aa:$vv:$ee" "" | tr '\n' ',' | sed 's/,$//;s/,/, /g')]"
            echo "::error::version $v is already published as a package for artifact $aa. Existing versions: $versionList"
            exit 99
        fi
    fi

    ### do the actual upload:
   uploadArtifactQuick "$token" "$gg:$aa:$vv:$ee" "$pom" "${files[@]}"
)
