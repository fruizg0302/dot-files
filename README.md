# Dotfiles

Neovim configuration built on [LazyVim](https://www.lazyvim.org/), optimized for web development with Ruby on Rails, TypeScript/JavaScript, and HTML/CSS.

## Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/dot-files.git ~/dot-files

# Symlink nvim config
ln -s ~/dot-files/nvim ~/.config/nvim

# Start Neovim (plugins install automatically)
nvim
```

**Requirements:** Neovim >= 0.9.0, Git, a [Nerd Font](https://www.nerdfonts.com/)

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
- Catppuccin Frappe

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
