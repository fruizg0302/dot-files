-- import nvim-tree plugin safely
local setup, nvimtree = pcall(require, "nvim-tree")
if not setup then
	return
end

-- recommended settings from nvim-tree documentation
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1

-- change color for arrows in tree to light blue
vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

-- configure nvim-tree
nvimtree.setup({
	-- change folder arrow icons
	view = {
		adaptive_size = true,
		centralize_selection = true,
		width = 30,
		side = "left",
		preserve_window_proportions = false,
		number = false,
		relativenumber = false,
		signcolumn = "yes",
	},
	renderer = {
		highlight_opened_files = "all",
		root_folder_label = false,
		icons = {
			glyphs = {
				folder = {
					arrow_closed = "", -- arrow when folder is closed
					arrow_open = "", -- arrow when folder is open
				},
				git = {
					unstaged = "✗",
					staged = "✓",
					unmerged = "",
					renamed = "➜",
					untracked = "★",
					deleted = "",
					ignored = "◌",
				},
			},
		},
	},
	-- disable window_picker for
	-- explorer to work well with
	-- window splits
	git = {
		enable = true,
		ignore = true,
		show_on_dirs = true,
		timeout = 400,
	},
	filesystem_watchers = {
		enable = false,
		debounce_delay = 50,
	},
	actions = {
		open_file = {
			quit_on_open = false,
			resize_window = true,
			window_picker = {
				enable = false,
			},
		},
		file_popup = {
			open_win_config = {
				col = 1,
				row = 1,
				relative = "cursor",
				border = "shadow",
				style = "minimal",
			},
		},
	},
})
vim.cmd("highlight NvimTreeFolderIcon guifg=#3FC5FF")
vim.cmd("highlight NvimTreeFolderName guifg=#51B3EC")
vim.cmd("highlight NvimTreeOpenedFolderName guifg=#FB508F")
vim.cmd("highlight NvimTreeEmptyFolderName guifg=#657b83")
vim.cmd("highlight NvimTreeFileDeleted guifg=#FF0000")
vim.cmd("highlight NvimTreeFileDirty guifg=#FFCC00")
vim.cmd("highlight NvimTreeFileStaged guifg=#00FF00")

vim.cmd("highlight NvimTreeNormal guibg=NONE")
vim.cmd("highlight NvimTreeNormalNC guibg=NONE")