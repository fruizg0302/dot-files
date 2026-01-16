-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Indentation (2 spaces is standard for Ruby, JS, HTML)
opt.tabstop = 2
opt.shiftwidth = 2
opt.softtabstop = 2
opt.expandtab = true

-- File type associations
vim.filetype.add({
  extension = {
    erb = "eruby",
    jbuilder = "ruby",
    rake = "ruby",
    gemspec = "ruby",
    ru = "ruby",
  },
  filename = {
    ["Gemfile"] = "ruby",
    ["Rakefile"] = "ruby",
    ["Guardfile"] = "ruby",
    [".rubocop.yml"] = "yaml",
    [".eslintrc"] = "json",
    [".prettierrc"] = "json",
  },
  pattern = {
    [".*%.env.*"] = "sh",
  },
})
