# upload-maven-package-action
upload a file as a maven package to the github package registry

## Example Usage

```yaml
- name: Upload a package
  uses: ModelingValueGroup/upload-maven-package-action@master
  with:
    numOctocats: 24
    octocatEyeColor: green
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
