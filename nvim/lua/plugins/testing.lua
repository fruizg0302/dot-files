-- Test adapters for JavaScript/TypeScript and Ruby
return {
  -- Jest adapter for JavaScript/TypeScript
  {
    "nvim-neotest/neotest-jest",
  },

  -- Minitest adapter for Ruby
  {
    "zidhuss/neotest-minitest",
  },

  -- Configure neotest with adapters
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-jest",
      "zidhuss/neotest-minitest",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          jestCommand = "npm test --",
          jestConfigFile = "jest.config.js",
          env = { CI = true },
          cwd = function()
            return vim.fn.getcwd()
          end,
        },
        ["neotest-minitest"] = {
          -- Uses bundle exec by default
        },
        ["neotest-rspec"] = {
          -- Use bundler's rspec instead of system-wide
          rspec_cmd = function()
            return vim.tbl_flatten({
              "bundle",
              "exec",
              "rspec",
            })
          end,
        },
      },
    },
  },
}
