<div align="center">

# mise-zig [![Build](https://github.com/dixonwille/mise-zig/actions/workflows/build.yml/badge.svg)](https://github.com/dixonwille/mise-zig/actions/workflows/build.yml) [![Lint](https://github.com/dixonwille/mise-zig/actions/workflows/lint.yml/badge.svg)](https://github.com/dixonwille/mise-zig/actions/workflows/lint.yml)

[zig](https://ziglang.org) plugin for the [mise](https://mise.jdx.dev).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `jq`: https://jqlang.github.io/jq/

# Install

Plugin:

```shell
mise plugins install zig https://github.com/dixonwille/mise-zig.git
```

zig:

```shell
# Show all installable versions
mise ls-remote zig

# Show aliases
mise aliases ls zig

# Use specific version for current project
mise use zig@nightly

# Use specific version globally
mise use -g zig@2024.1.0-mach

# Now zig commands are available
zig version
```

Check [mise](https://mise.jdx.dev/getting-started.html) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/dixonwille/mise-zig/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Will Dixon](https://github.com/dixonwille/)
