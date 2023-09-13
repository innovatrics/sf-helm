# Release process

- update CHANGELOG.md
- update version in Chart.yaml
- push new tag `v{major}.{minor}.{patch}` e.g. `v1.2.1` to trigger publish pipeline
- CI will create a new release
    - CI will check if chart version matches the tag version and will fail if they don't
- CI created a draft release, publish it to make the release public
