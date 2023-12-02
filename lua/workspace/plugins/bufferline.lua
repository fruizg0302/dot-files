require("bufferline").setup({
	options = {
		mode = "buffers",
		numbers = "both",
		close_command = "bdelete",
		buffer_close_icon = "",
		modified_icon = "●",
		close_icon = "",
		left_trunc_marker = "",
		right_trunc_marker = "",
		color_icons = true,
		separator_style = "slant",
		show_tab_indicators = true,
		diagnostics = "nvim_lsp",
		enforce_regular_tabs = false,
        always_show_bufferline = false,
		custom_areas = {
            right = function()
                local result = {}
                if vim.fn.exists("*nvim_tree_find_file") == 1 then
                    local icon = vim.fn["nvim_tree_find_file"]() and "פּ" or ""
                    table.insert(result, {text = icon, guifg = "#A1EFD3"})
                end
                return result
            end,
        },
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				text_align = "left",
				separator = true,
			},
		},
	},
	highlights = {
		fill = {
            guibg = { attribute = "bg", highlight = "TabLine" }
        },
		separator = {
			fg = "#073642",
			bg = "#002b36",
		},
		separator_selected = {
			fg = "#073642",
		},
		background = {
			fg = "#657b83",
			bg = "#002b36",
		},
		buffer_selected = {
			fg = "#fdf6e3",
			bold = true,
		},
		fill = {
			bg = "#073642",
		},
	},
})
