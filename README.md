# upload-maven-package-action
upload a file as a maven package to the github package registry

## Example Usage

When _gave_ (group-artifact-version-extension) can be taken from pom.xml:
```yaml
      - name: "Upload as package"
        uses: ModelingValueGroup/upload-maven-package-action@master
        with:
          file: "myfile"
```
Or when no pom is present:
```yaml
      - name: "Upload as package"
        uses: ModelingValueGroup/upload-maven-package-action@master
        with:
          file: "myfile"
          gave: "group:artifact:version:ext"
```
