return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      -- The Elixir extra replaces this table; retain the existing language linters.
      linters_by_ft = {
        fish = { "fish" },
        dockerfile = { "hadolint" },
      },
    },
  },
}
