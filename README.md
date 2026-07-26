# Dotfiles

Personal configuration for zsh, Neovim, oh-my-posh, and ripgrep. The Neovim setup is built on [LazyVim](https://www.lazyvim.org/), optimized for web development with Ruby on Rails, TypeScript/JavaScript, and HTML/CSS.

## Installation

```bash
# Clone the repository. The path is up to you — machines in use have it at
# both ~/dot-files and ~/workspace/PERSONAL/Config/dot-files.
git clone https://github.com/fruizg0302/dot-files.git ~/dot-files
DOTFILES=~/dot-files

# Symlink configs
ln -sfn "$DOTFILES/zsh/zshrc" ~/.zshrc
ln -sfn "$DOTFILES/oh-my-posh" ~/.config/oh-my-posh
ln -sfn "$DOTFILES/ripgrep" ~/.config/ripgrep

# Neovim runs under the `lazyvim` app-name: the shell exports
# NVIM_APPNAME=lazyvim, so `nvim` loads this config from ~/.config/lazyvim and
# keeps its data in ~/.local/share/lazyvim.
#
# Deliberately NOT linking ~/.config/nvim as well. That looks harmless, but
# anything starting Neovim without the shell environment (Raycast, Finder,
# "Open with", cron) never sees NVIM_APPNAME, reads ~/.config/nvim, and
# quietly bootstraps a SECOND full plugin and Mason tree under
# ~/.local/share/nvim (94M of duplicates on the machine where this was found).
#
# With only ~/.config/lazyvim present, such a launch gets a config-less
# vanilla Neovim: no plugins, no keymaps, and no second tree — it recreates
# ~/.local/share/nvim but leaves it empty. That is quiet, not loud, so don't
# expect an error; you notice it the moment a leader key does nothing.
ln -sfn "$DOTFILES/nvim" ~/.config/lazyvim

# Start Neovim (plugins install automatically)
nvim

# Then pin plugins to the tracked lockfile — see "After pulling" below
nvim --headless "+Lazy! restore" +qa
```

> **Note:** Because of `NVIM_APPNAME=lazyvim`, Neovim reads `~/.config/lazyvim`
> and stores data under `~/.local/share/lazyvim`. If the repo moves and this
> symlink is left dangling, `nvim` silently falls back to the vanilla editor.

## Machine-local configuration (`~/.zshrc.local`)

`zsh/zshrc` is shared across machines. Anything private, host-specific, or
path-dependent goes in `~/.zshrc.local`, which is never tracked and is sourced
at the very end — so it also wins on any conflict.

**This repo is public.** Secrets, and anything naming internal infrastructure
(hosts, client projects, registry credentials), must not go in the tracked
zshrc. Secret *values* live in the macOS Keychain and are read on demand with
`security find-generic-password` — never written to disk in either file.

### After pulling on a machine that isn't the one this was set up on

Three things are worth checking:

**0. Sync plugins to the lockfile — this is the one that bites.**

```bash
nvim --headless "+Lazy! restore" +qa
```

`lazy-lock.json` is tracked, so a pull can move 40+ plugins' pinned commits
while the machine keeps running whatever it installed months ago. Nothing warns
you. Plugins only move when you actually restore, and the gap shows up later as
plugin errors that look like config bugs but are just version skew — see
[Troubleshooting](#troubleshooting) for the case that prompted this note.

To see the drift first without changing anything (`:Lazy check` won't tell you —
it fetches remote update logs, which is a different question):

```bash
nvim --headless -c 'lua
  local lock = vim.fn.json_decode(table.concat(
    vim.fn.readfile(vim.fn.stdpath("config") .. "/lazy-lock.json"), "\n"))
  local drift = {}
  for name, info in pairs(lock) do
    local dir = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy", name)
    if not vim.uv.fs_stat(dir) then
      drift[#drift + 1] = name .. " (missing)"
    elseif vim.fn.system({ "git", "-C", dir, "rev-parse", "HEAD" }):gsub("%s+", "") ~= info.commit then
      drift[#drift + 1] = name
    end
  end
  table.sort(drift)
  print(("%d/%d out of sync%s"):format(#drift, vim.tbl_count(lock),
    #drift > 0 and ": " .. table.concat(drift, ", ") or ""))
' -c qa
```

**1. Set `WORKSPACE` if your code doesn't live in `~/workspace`.** `wks` and any
project shortcuts resolve through it. The tracked default is `$HOME/workspace`,
so on a machine that keeps its workspace elsewhere (an external volume, for
example) add:

```zsh
# ~/.zshrc.local
WORKSPACE=/Volumes/YourVolume/workspace
```

This replaced a hardcoded `wks` alias that pointed at one machine's external
drive and silently did nothing everywhere else.

**2. The prompt degrades on purpose.** `zshrc` uses oh-my-posh when it's
installed *and* `~/.config/oh-my-posh/atomic.omp.json` resolves, and otherwise
falls back to starship. A machine with neither gets no prompt, so install at
least one. Every other optional tool is guarded the same way through the
`_cached_init` helper, which returns early when the tool is missing — so a
partially-provisioned machine still boots a working shell instead of erroring.

**Requirements:** Neovim >= 0.9.0, Git, a [Nerd Font](https://www.nerdfonts.com/), and a prompt (oh-my-posh *or* starship).

Optional, each independently guarded — install what you use: fzf, fd, bat, eza, zoxide, direnv, atuin, mise, lazygit, yazi, zsh-autosuggestions, zsh-syntax-highlighting (all via Homebrew).

## Troubleshooting

### A wall of plugin errors on every file open

**Restore to the lockfile before debugging anything.** Neovim is tracked on
`nightly` here, and a nightly bump can delete an API that installed plugins
still call. The error names the plugin, so it reads like a config bug; it
usually isn't.

Real case: Neovim **v0.13 removed the `BufModifiedSet` autocmd event**. The
installed dropbar.nvim still registered it, `nvim_create_autocmd` threw, and the
failure cascaded through every `FileType` autocmd — so *any* file open produced
a stack trace. The fixed dropbar commit was already pinned in `lazy-lock.json`;
the machine had simply never restored to it. `+Lazy! restore` was the entire fix.

Confirm whether an event/API still exists in the running Neovim:

```bash
nvim --clean --headless -c 'lua print(vim.inspect(vim.fn.getcompletion("Buf", "event")))' -c qa
```

### Moving `~/.local/share/lazyvim` (or renaming the app-name)

**A plain `mv` silently breaks Mason.** Some packages record absolute paths —
symlinks in `mason/bin` and interpreter lines inside wrapper scripts — so they
keep pointing at the old location and fail only when invoked.

After moving, repoint them:

```bash
OLD=~/.local/share/nvim NEW=~/.local/share/lazyvim
cd "$NEW"
find mason -type l -lname "$OLD/*" | while read -r l; do
  ln -sfn "$(readlink "$l" | sed "s|$OLD|$NEW|")" "$l"
done
rg -l -F "$OLD" mason --max-filesize 2M | xargs sed -i '' "s|$OLD|$NEW|g"
find mason -type l ! -exec test -e {} \; -print   # should print nothing
```

### Ruby: RuboCop and `ruby_lsp`

**RuboCop deliberately has no standalone LSP server.** Mason's rubocop runs from
its own gem path, so it cannot resolve `inherit_gem:` — which every
`rubocop-rails-omakase` project uses — and exits 2. `ruby-lsp` ships a RuboCop
addon that runs inside the project bundle at the version the project pins, so it
is the only RuboCop configured. Don't re-add `rubocop` to `ensure_installed` or
to conform's `formatters_by_ft`; see `nvim/lua/plugins/web.lua`.

**If `ruby_lsp` itself quits, it's the project, not this config.** Check in the
project directory, in a normal interactive shell so mise's `chpwd` hook fires:

```bash
mise current ruby   # "missing: ruby@X" means mise falls back to system ruby 2.6
bundle check        # "The following gems are missing" -> bundle install
```

A `cannot load such file -- prism/translation/parserNN` error from `ruby_lsp` is
this same mismatch: the project is running under the wrong Ruby.

## Features

### Language Support

| Language | LSP | Formatter | Linter |
|----------|-----|-----------|--------|
| Ruby/Rails | Solargraph | Rubocop | Rubocop |
| TypeScript/JavaScript | tsserver | Prettier | ESLint |
| HTML/ERB | html-lsp, emmet | Prettier, erb-lint | - |
| CSS/SCSS | cssls, stylelint | Prettier | Stylelint |
| JSON/YAML | Built-in | Prettier | - |
| Lua | lua_ls | StyLua | - |
| Docker | dockerls, docker-compose | - | hadolint |

### Plugins

**Web Development**
- `vim-rails` - Rails navigation and commands
- `nvim-ts-autotag` - Auto-close/rename HTML tags
- `nvim-treesitter-endwise` - Auto-insert `end` for Ruby blocks
- `nvim-colorizer.lua` - CSS color highlighting
- `package-info.nvim` - npm package version info
- `vim-matchup` - Enhanced `%` matching for blocks and tags

**Testing**
- `neotest` with Minitest adapter

**AI Integration**
- `claudecode.nvim` - Claude Code integration

**Theme**
- token (ThorstenRhau/token), with Catppuccin Frappe available

## Key Bindings

Leader key: `Space`

### Claude Code (`<leader>a`)

| Key | Action |
|-----|--------|
| `<leader>ac` | Toggle Claude terminal |
| `<leader>af` | Focus Claude terminal |
| `<leader>ar` | Resume previous session |
| `<leader>aC` | Continue conversation |
| `<leader>am` | Select model |
| `<leader>ab` | Add current buffer to context |
| `<leader>as` | Send selection to Claude (visual mode) |
| `<leader>aa` | Accept diff |
| `<leader>ad` | Deny diff |

### LazyVim Defaults

See [LazyVim Keymaps](https://www.lazyvim.org/keymaps) for the full list. Common ones:

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>/` | Live grep |
| `<leader>e` | File explorer |
| `<leader>gg` | Lazygit |
| `<leader>xx` | Diagnostics |
| `<leader>cf` | Format |
| `<leader>cr` | Rename |
| `<leader>ca` | Code action |

## LazyVim Extras

Enabled extras (configured in `lazyvim.json`):

- `lang.typescript` - TypeScript support
- `lang.ruby` - Ruby/Rails support
- `lang.json` - JSON support
- `lang.yaml` - YAML support
- `lang.tailwind` - Tailwind CSS support
- `formatting.prettier` - Prettier integration
- `linting.eslint` - ESLint integration
- `util.octo` - GitHub integration
- `test.core` - Testing framework
- `lang.docker` - Dockerfile and docker-compose support

## Structure

```
zsh/
└── zshrc                 # Shell config (history, aliases, fzf, cached tool inits)
oh-my-posh/
├── atomic.omp.json       # Prompt theme
├── claude-statusline.omp.json
└── developer.omp.json
ripgrep/
└── config                # Smart-case, max filesize, custom file types
nvim/
├── init.lua              # Entry point
├── lazyvim.json          # LazyVim extras config
├── lazy-lock.json        # Plugin lockfile
├── stylua.toml           # Lua formatter config
└── lua/
    ├── config/
    │   ├── autocmds.lua  # Auto commands
    │   ├── keymaps.lua   # Custom keymaps
    │   ├── lazy.lua      # Plugin manager setup
    │   └── options.lua   # Editor options
    └── plugins/
        ├── claude.lua    # Claude Code integration
        ├── colorscheme.lua
        ├── testing.lua   # Neotest config
        └── web.lua       # Web dev plugins
```

## Customization

- **Add plugins:** Create a new file in `nvim/lua/plugins/`
- **Change theme:** Edit `nvim/lua/plugins/colorscheme.lua`
- **Add keymaps:** Edit `nvim/lua/config/keymaps.lua`
- **Enable extras:** Use `:LazyExtras` in Neovim

## Code Style

- 2-space indentation (Ruby, JS, HTML, Lua)
- Lua: StyLua with 120 column width
- Prettier for web languages
- Rubocop for Ruby
