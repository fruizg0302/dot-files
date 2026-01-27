-- Testing Configuration (Minitest, RSpec, Jest)
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "zidhuss/neotest-minitest",
    },
    opts = {
      adapters = {
        ["neotest-minitest"] = {},
      },
    },
  },
}
