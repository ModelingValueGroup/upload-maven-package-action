# upload-maven-package-action
upload a file as a maven package to the github package registry

## Example Usage

When gave can be taken from pom.xml:
```yaml
      - name: "Upload as package"
        uses: ModelingValueGroup/upload-maven-package-action@master
        with:
          file: "tools.sh"
          token: "${{ secrets.GITHUB_TOKEN }}"
```
Or when no pom is present:
```yaml
      - name: "Upload as package"
        uses: ModelingValueGroup/upload-maven-package-action@master
        with:
          file: "tools.sh"
          gave: "group:artifact:version:ext"
          token: "${{ secrets.GITHUB_TOKEN }}"
```
