# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles: zsh (`zsh/zshrc` loader plus numbered modules in `zsh/conf.d/`), oh-my-posh themes (`oh-my-posh/`), ripgrep (`ripgrep/`), Ghostty (`ghostty/`), and a Neovim configuration using the LazyVim framework, optimized for web development with Ruby on Rails, TypeScript/JavaScript, and HTML/CSS.

Live configs are symlinks into this repo: `~/.zshrc`, `~/.config/lazyvim`, `~/.config/oh-my-posh`, `~/.config/ripgrep`, `~/.config/ghostty`. Machine-local secrets stay in `~/.zshrc.local` (untracked); never add secrets or internal hostnames here — the repo is public.

## Architecture

- Entry point: `nvim/init.lua`
- Plugin manager: Lazy.nvim with LazyVim framework
- Configuration structure:
  - `nvim/lua/config/` - Core settings (options, keymaps, autocmds)
  - `nvim/lua/plugins/` - Plugin specifications
  - `nvim/lazyvim.json` - LazyVim extras configuration

The `nvim/` directory is symlinked into place. The repo path is machine-local
(`~/dot-files` on some machines, `~/workspace/PERSONAL/Config/dot-files` on
others), so prefer relative references over hardcoding it.

The shell exports `NVIM_APPNAME=lazyvim`, so **only `~/.config/lazyvim` is
linked at `nvim/`** — `~/.config/nvim` is deliberately absent. The app-name
selects the *data* dir:

- `NVIM_APPNAME=lazyvim` → config `~/.config/lazyvim`, data `~/.local/share/lazyvim/` (Mason packages live here)
- app-name unset → config `~/.config/nvim` (absent), data `~/.local/share/nvim/`

Don't "helpfully" add the `~/.config/nvim` symlink back. It makes every
env-less launch (Raycast, Finder, cron) bootstrap a duplicate plugin and Mason
tree under `~/.local/share/nvim`; see the Installation comment in `README.md`.
Without it, those launches get a config-less vanilla Neovim — quiet, but
cheap and obvious.

Plugin specs that reference a Mason binary should use an absolute
`~/.local/share/lazyvim/mason/bin/...` path rather than relying on the
app-name resolving. If the repo moves and `~/.config/lazyvim` is left
dangling, `nvim` silently falls back to the vanilla editor.

## Key Bindings (Space as Leader)

### Buffer/Window Management
- `<leader>pb/nb` - Previous/next buffer
- `<leader>db` - Delete buffer
- `<leader>sv/sh` - Split vertical/horizontal
- `<leader>sx` - Close split
- `<leader>to/tx/tn/tp` - Tab operations

### Navigation & Search
- `<leader>e` - Toggle file explorer (nvim-tree)
- `<leader>ff` - Find files (includes hidden)
- `<leader>fs` - Live grep
- `<leader>fc` - Grep string under cursor
- `<leader>fb` - List buffers

### Git (Telescope)
- `<leader>gc` - Git commits
- `<leader>gb` - Git branches
- `<leader>gs` - Git status

### LSP
- `<leader>rs` - Restart LSP server

## Code Style

- 2-space indentation (standard for Ruby, JS, HTML)
- Lua formatting: StyLua with 2-space indent, 120 column width
- Prettier for TypeScript, JavaScript, HTML, CSS, JSON, YAML
- RuboCop for Ruby — via ruby-lsp's addon, not conform and not a standalone
  server (see Language Support below)
- ESLint for JavaScript/TypeScript linting

## Language Support

Configured language servers (via Mason): TypeScript, HTML, CSS, Lua, Ruby
(Solargraph), GraphQL, SQL, YAML, Elixir (Expert)

LazyVim extras enabled: TypeScript, Ruby, JSON, YAML, Tailwind CSS, Prettier, ESLint

Two servers are deliberately disabled — both cases of one language getting two
servers on the same buffer:

- **`rubocop`** (`servers.rubocop = false` in `nvim/lua/plugins/web.lua`). Mason's
  rubocop runs from its own gem path and cannot resolve `inherit_gem:`, so it
  exits 2 on any `rubocop-rails-omakase` project. ruby-lsp's RuboCop addon runs
  inside the project bundle at the project's pinned version instead.
- **ElixirLS**, by not enabling `lazyvim.plugins.extras.lang.elixir` — see the
  comment at the top of `nvim/lua/plugins/elixir.lua`.

## Plugin versions

`nvim/lazy-lock.json` is tracked and authoritative. After pulling, run
`nvim --headless "+Lazy! restore" +qa` — a pull can move dozens of pinned
commits while the machine keeps running what it installed months ago, and the
skew surfaces later as plugin errors that look like config bugs. Neovim tracks
`nightly` here, so a removed API in a nightly bump plus stale plugins is the
most likely cause of sudden breakage.

## File Type Associations

Custom mappings in `nvim/lua/config/options.lua`:
- `.erb`, `.jbuilder`, `.rake`, `.gemspec`, `.ru` → Ruby
- `Gemfile`, `Rakefile`, `Guardfile` → Ruby
- `.env*` files → Shell
