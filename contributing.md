# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

# TODO: adapt this
asdf plugin test zig https://github.com/dixonwille/mise-zig.git "zig --version"
```

Tests are automatically run in GitHub Actions on push and PR.
