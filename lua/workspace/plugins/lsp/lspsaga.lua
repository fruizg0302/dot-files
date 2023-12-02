-- import lspsaga safely
local saga_status, saga = pcall(require, "lspsaga")
if not saga_status then
	return
end

saga.setup({
	border_style = "round",
	saga_winblend = 30,
	max_preview_lines = 10,
	move_in_saga = { prev = "<C-k>", next = "<C-j>" },
	finder_action_keys = {
		open = "<CR>",
	},
	definition_action_keys = {
		edit = "<CR>",
	},
	hover_doc = {
        max_width = 80,
        max_height = 40,
        use_lspsaga_hover = true,
    },
})
local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<C-j>", "<Cmd>Lspsaga diagnostic_jump_next<CR>", opts)
vim.keymap.set("n", "gd", "<Cmd>Lspsaga lsp_finder<CR>", opts)
vim.keymap.set("i", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
vim.keymap.set("n", "gp", "<Cmd>Lspsaga peek_definition<CR>", opts)
vim.keymap.set("n", "gr", "<Cmd>Lspsaga rename<CR>", opts)
vim.keymap.set("n", "<leader>ltt", "<Cmd>Lspsaga term_toggle<CR>", opts)

vim.cmd([[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false, scope="cursor"})]])
vim.cmd([[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]])

vim.cmd("highlight LspSagaDiagnosticBorder guibg='#1E1E1E'")
vim.cmd("highlight LspSagaHoverBorder guibg='#1E1E1E'")
vim.cmd("highlight LspSagaSignatureHelpBorder guifg='#FF61EF'")

vim.cmd("highlight LspSagaDiagnosticTruncateLine guifg='#C5CDD9'")
vim.cmd("highlight LspDiagnosticsDefaultError guifg='#E06C75'")
vim.cmd("highlight LspDiagnosticsDefaultWarning guifg='#E5C07B'")
vim.cmd("highlight LspDiagnosticsDefaultInformation guifg='#61AFEF'")
vim.cmd("highlight LspDiagnosticsDefaultHint guifg='#98C379'")

