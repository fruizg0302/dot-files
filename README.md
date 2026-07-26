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
# NVIM_APPNAME=lazyvim, so plain `nvim` loads this config from ~/.config/lazyvim
# and keeps its data in ~/.local/share/lazyvim. Linking ~/.config/nvim as well
# is harmless and makes the config work with NVIM_APPNAME unset.
ln -sfn "$DOTFILES/nvim" ~/.config/lazyvim
ln -sfn "$DOTFILES/nvim" ~/.config/nvim

# Start Neovim (plugins install automatically)
nvim
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

Two things are worth checking:

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
