-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
	return
end

-- import cmp-nvim-lsp plugin safely
local cmp_nvim_lsp_status, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_nvim_lsp_status then
	return
end

-- import typescript plugin safely
local typescript_setup, typescript = pcall(require, "typescript")
if not typescript_setup then
	return
end

local keymap = vim.keymap -- for conciseness

-- enable keybinds only for when lsp server available
local on_attach = function(client, bufnr)
	-- keybind options
	local opts = { noremap = true, silent = true, buffer = bufnr }
	-- set keybinds

	--lsp saga configuration
	keymap.set("n", "<C-j>", "<Cmd>Lspsaga diagnostic_jump_next<CR>", opts)
	keymap.set("i", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
	keymap.set("n", "<leader>gp", "<Cmd>Lspsaga peek_definition<CR>", opts)
	keymap.set("n", "<leader>gr", "<Cmd>Lspsaga rename<CR>", opts)
	keymap.set("n", "<leader>ltt", "<Cmd>Lspsaga term_toggle<CR>", opts)
	keymap.set("n", "<leader>gf", "<cmd>Lspsaga lsp_finder<CR>", opts) -- show definition, references
	keymap.set('n', '<leader>gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts) -- go to definition
	keymap.set('n', '<leader>gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts) -- go to declaration
	keymap.set("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", opts) -- see outline on right hand side

	-- run the codelens under the cursor
	keymap.set("n", "<leader>r", vim.lsp.codelens.run, opts)
	-- remove the pipe operator
	keymap.set("n", "<leader>fp", ":ElixirFromPipe<cr>", opts)
	-- add the pipe operator
	keymap.set("n", "<leader>tp", ":ElixirToPipe<cr>", opts)
	keymap.set("v", "<leader>em", ":ElixirExpandMacro<cr>", opts)

	-- typescript specific keymaps (e.g. rename file and update imports)
	if client.name == "tsserver" then
		keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>") -- rename file and update imports
		keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>") -- organize imports (not in youtube nvim video)
		keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>") -- remove unused variables (not in youtube nvim video)
	end

	vim.api.nvim_create_autocmd("CursorHold", {
		buffer = bufnr,
		callback = function()
			local opts = {
				focusable = false,
				close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
				border = "rounded",
				source = "always",
				prefix = " ",
				scope = "cursor",
			}
			vim.diagnostic.open_float(nil, opts)
		end,
	})
end

-- used to enable autocompletion (assign to every lsp server config)
-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "ﴞ ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

local capabilities = cmp_nvim_lsp.default_capabilities()

-- configure html server
lspconfig["html"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

local handlers = {
	["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
		virtual_text = false,
	}),
}
local function custom_root_dir(fname)
    local util = require('lspconfig.util')
    -- Search for root directory based on given patterns
    return util.root_pattern("Gemfile", ".git", ".rubocop.yml")(fname)
           or util.path.dirname(fname)
end


lspconfig["solargraph"].setup({
	cmd = {
		"solargraph",
		"stdio",
	},
	filetypes = {
		"ruby",
	},
	flags = {
		debounce_text_changes = 150,
	},
	on_attach = on_attach,
	root_dir = custom_root_dir,
	capabilities = capabilities,
	handlers = handlers,
	settings = {
		solargraph = {
			completion = true,
			diagnostic = true,
			folding = true,
			references = true,
			rename = true,
			symbols = true,
		},
	},
})

-- configure typescript server with plugin
typescript.setup({
	server = {
		capabilities = capabilities,
		on_attach = on_attach,
	},
})

-- configure css server
lspconfig["cssls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure tailwindcss server
lspconfig["tailwindcss"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure elixir lsp server
lspconfig["elixirls"].setup({
	cmd = { os.getenv("HOME") .. "/.elixir_ls/language_server.sh" },
	settings = {
		dialyzerEnabled = true,
		fetchDeps = false,
		enableTestLenses = false,
		suggestSpecs = false,
	},
})

-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = { -- custom settings for lua
		Lua = {
			-- make the language server recognize "vim" global
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- make language server aware of runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
})
