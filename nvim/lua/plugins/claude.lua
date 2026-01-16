return {
  "coder/claudecode.nvim",
  config = true,
  keys = {
    { "<leader>ac", "<cmd>ClaudeCodeToggle<cr>", desc = "Toggle Claude Code" },
    { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
  },
}
