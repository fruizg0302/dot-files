-- Web Development Configuration (Ruby on Rails, TypeScript, JavaScript, HTML)
return {
  -- Treesitter: ensure all web-related parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "css",
        "html",
        "javascript",
        "json",
        "json5",
        "jsonc",
        "lua",
        "ruby",
        "scss",
        "tsx",
        "typescript",
        "yaml",
        "embedded_template", -- ERB support
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- HTML
        html = {
          filetypes = { "html", "eruby" },
        },
        -- CSS
        cssls = {},
        -- Emmet for fast HTML/CSS editing
        emmet_ls = {
          filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "eruby" },
        },
        -- The standalone RuboCop server runs from Mason's own gem path, so it
        -- can't resolve `inherit_gem:` (rubocop-rails-omakase and friends) and
        -- dies with exit 2 on any modern Rails project. ruby-lsp already ships
        -- a RuboCop addon that runs inside the project bundle, at the version
        -- the project actually pins — so this one is both broken and redundant.
        rubocop = false,
      },
    },
  },

  -- Mason: ensure all necessary tools are installed
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        -- Ruby/Rails. RuboCop deliberately absent: ruby-lsp's addon supplies it
        -- from the project bundle (see the lspconfig block above).
        "solargraph",
        "erb-lint",
        -- TypeScript/JavaScript
        "typescript-language-server",
        "eslint-lsp",
        "prettier",
        -- HTML/CSS
        "html-lsp",
        "css-lsp",
        "emmet-ls",
        "stylelint-lsp",
        -- General
        "stylua",
        "shellcheck",
        "shfmt",
      },
    },
  },

  -- Formatter configuration
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- No conform formatter for Ruby: it would shell out to Mason's rubocop
        -- and hit the same `inherit_gem:` failure. Falling through to LSP
        -- formatting hands it to ruby-lsp, which resolves the project bundle.
        eruby = { "erb_lint" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
      },
    },
  },

  -- Rails-specific plugin
  {
    "tpope/vim-rails",
    ft = { "ruby", "eruby", "yaml" },
    dependencies = {
      "tpope/vim-bundler",
      "tpope/vim-dispatch",
    },
  },

  -- Ruby block text objects and motions (auto-insert 'end')
  {
    "RRethy/nvim-treesitter-endwise",
    event = "InsertEnter",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- Auto-close and rename HTML tags
  {
    "windwp/nvim-ts-autotag",
    opts = {
      opts = {
        enable_close = true,
        enable_rename = true,
        enable_close_on_slash = true,
      },
      per_filetype = {
        ["eruby"] = { enable_close = true },
      },
    },
  },

  -- Better % matching for Ruby blocks, HTML tags, etc.
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  -- Color highlighting for CSS colors
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = { "css", "scss", "html", "javascript", "typescript", "eruby" },
      user_default_options = {
        css = true,
        tailwind = true,
      },
    },
  },

  -- Package.json dependency info
  {
    "vuki656/package-info.nvim",
    dependencies = "MunifTanjim/nui.nvim",
    ft = "json",
    opts = {},
  },
}
