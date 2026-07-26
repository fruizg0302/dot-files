-- Elixir / Phoenix support.
--
-- Deliberately NOT using `lazyvim.plugins.extras.lang.elixir`: that extra wires
-- up ElixirLS, and running it alongside Expert gives you two servers fighting
-- over the same buffer. Expert (github.com/elixir-lang/expert) is the
-- consolidated successor to ElixirLS/Lexical/NextLS.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "elixir", "eex", "heex", "erlang" })
      end
    end,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        expert = {
          -- Absolute path so this works when nvim is launched from a GUI
          -- (Raycast, Finder, etc.) where the shell PATH isn't inherited.
          cmd = { vim.fn.expand("~/.local/share/lazyvim/mason/bin/expert"), "--stdio" },
          filetypes = { "elixir", "eelixir", "heex", "surface" },
        },
      },
    },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        elixir = { "mix" },
        eelixir = { "mix" },
        heex = { "mix" },
      },
    },
  },
}
