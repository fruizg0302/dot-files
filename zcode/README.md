# ZCode on the PX13

Selected changes from 2026-11-17, not a backup of the complete ZCode config.
Credentials, providers, model settings, conversations, and databases are excluded.

## Terminal launcher

`home/.local/bin/zcode` preserves the working source-build launcher. It runs
the installed mise Node **22.23.5**, rather than the global Node 26 runtime
that fails with `Node FFI backend does not support usize`.

The launcher expects:

- Node at `~/.local/share/mise/installs/node/22.23.5/bin/node`.
- A built ZCode CLI at `~/src/ZCode/apps/zcode-cli/packages/cli/dist/zcode.cjs`.
- The captured source build was at commit
  `29628c9acdb81b703bbd4080c207a0e7ce5e276e`.

Back up any existing launcher, then install this one from the checkout root:

```sh
install -Dm755 zcode/home/.local/bin/zcode "$HOME/.local/bin/zcode"
zcode --version
zcode --help
```

This does not install Node, build ZCode, or change the global Node version.
Open `zcode` in an interactive terminal to check the renderer too.

## Permission mode

`permission.json` is a **merge fragment**, not a replacement for
`~/.zcode/cli/config.json`. Back up that file and merge only
`permission.mode = "build"`. The installed ZCode build rejects tool calls in
`auto` mode; `build` allows reads and requests approval for commands and edits.
In an already-running conversation, use `/mode build` as well.

The [Herdr integration](../herdr/README.md#zcode-activity) installs the activity
hooks separately, preserving the rest of the local ZCode configuration.
