-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
	return
end

-- import telescope actions safely
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
	return
end

local keymaps = require("workspace.core.keymaps") 

-- configure telescope
telescope.setup({
	-- configure custom mappings
	defaults = {
		layout_strategy = "flex",
		layout_config = {
            vertical = { width = 0.9 },
            horizontal = { preview_width = 0.6 },
        },
		file_previewer = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        winblend = 15,
        borderchars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
        color_devicons = true,
        use_less = true,
        path_display = { "smart" },
		mappings = keymaps.setup_telescope_mappings(actions),
	},
})

telescope.load_extension("fzf")
