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
    -- Add-if-absent rather than a plain `opts` table.
    --
    -- LazyVim marks ensure_installed with `opts_extend`, so every spec's list
    -- is CONCATENATED, never deduplicated, and its config loop then calls
    -- pkg:install() once per entry. A package named both here and by LazyVim
    -- or one of the enabled extras therefore gets two install() calls in the
    -- same tick, the second asserts "Package is already installing", and that
    -- aborts mason.nvim's entire config block — no packages get installed at
    -- all, on every startup. Real overlaps here: stylua and shfmt (LazyVim
    -- base), erb-lint (lang.ruby), prettier (formatting.prettier).
    --
    -- LSP servers are deliberately absent: LazyVim installs a package for
    -- every entry in `opts.servers` through mason-lspconfig's own
    -- ensure_installed, which races this list for the same reason.
    opts = function(_, opts)
      local want = {
        -- Ruby/Rails. RuboCop deliberately absent: ruby-lsp's addon supplies it
        -- from the project bundle (see the lspconfig block above).
        "solargraph",
        "erb-lint",
        -- TypeScript/JavaScript
        "prettier",
        -- CSS
        "stylelint-lsp",
        -- General
        "stylua",
        "shellcheck",
        "shfmt",
      }

      local merged, seen = {}, {}
      for _, list in ipairs({ opts.ensure_installed or {}, want }) do
        for _, pkg in ipairs(list) do
          if not seen[pkg] then
            seen[pkg] = true
            merged[#merged + 1] = pkg
          end
        end
      end
      opts.ensure_installed = merged
      return opts
    end,
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
