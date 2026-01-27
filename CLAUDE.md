# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Neovim configuration repository using LazyVim framework, optimized for web development with Ruby on Rails, TypeScript/JavaScript, and HTML/CSS.

## Architecture

- Entry point: `nvim/init.lua`
- Plugin manager: Lazy.nvim with LazyVim framework
- Configuration structure:
  - `nvim/lua/config/` - Core settings (options, keymaps, autocmds)
  - `nvim/lua/plugins/` - Plugin specifications
  - `nvim/lazyvim.json` - LazyVim extras configuration

The `nvim/` directory is symlinked to `~/.config/nvim/`.

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
- Rubocop for Ruby
- ESLint for JavaScript/TypeScript linting

## Language Support

Configured language servers (via Mason): TypeScript, HTML, CSS, Lua, Ruby (Solargraph), GraphQL, SQL, YAML, Elixir

LazyVim extras enabled: TypeScript, Ruby, JSON, YAML, Tailwind CSS, Prettier, ESLint

## File Type Associations

Custom mappings in `nvim/lua/config/options.lua`:
- `.erb`, `.jbuilder`, `.rake`, `.gemspec`, `.ru` → Ruby
- `Gemfile`, `Rakefile`, `Guardfile` → Ruby
- `.env*` files → Shell
