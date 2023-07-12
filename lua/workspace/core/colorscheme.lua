local status, n = pcall(require, "catppuccin")
if not status then
	return
end

n.setup({
	flavour = "mocha", -- latte, frappe, macchiato, mocha
	background = { -- :h background
		light = "latte",
		dark = "mocha",
	},
	transparent_background = true, -- disables setting the background color.
	show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
	term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
	dim_inactive = {
		enabled = false, -- dims the background color of inactive window
		shade = "dark",
		percentage = 0.15, -- percentage of the shade to apply to the inactive window
	},
	no_italic = false, -- Force no italic
	no_bold = false, -- Force no bold
	no_underline = false, -- Force no underline
	styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
		comments = { "italic" }, -- Change the style of comments
		conditionals = { "italic" },
		loops = {},
		functions = {},
		keywords = {},
		strings = {},
		variables = {},
		numbers = {},
		booleans = {},
		properties = {},
		types = {},
		operators = {},
	},
	color_overrides = {},
	custom_highlights = {},
	integrations = {
		cmp = true,
		gitsigns = true,
		nvimtree = true,
		telescope = true,
		notify = false,
		mini = false,
		lsp_saga = true,
		treesitter = true,
		treesitter_context = true,
		nvimtree = true
		-- For more plugins integrations please scroll down (https://github.com/catppuccin/nvim#integrations)
	},
})
--[[
n.setup({
	--- @usage 'auto'|'main'|'moon'|'dawn'
	variant = 'auto',
	--- @usage 'main'|'moon'|'dawn'
	dark_variant = 'moon',
	bold_vert_split = false,
	dim_nc_background = false,
	disable_background = false,
	disable_float_background = false,
	disable_italics = false,

	--- @usage string hex value or named color from rosepinetheme.com/palette
	groups = {
		background = 'base',
		background_nc = '_experimental_nc',
		panel = 'surface',
		panel_nc = 'base',
		border = 'highlight_med',
		comment = 'muted',
		link = 'iris',
		punctuation = 'subtle',

		error = 'love',
		hint = 'iris',
		info = 'foam',
		warn = 'gold',

		headings = {
			h1 = 'iris',
			h2 = 'foam',
			h3 = 'rose',
			h4 = 'gold',
			h5 = 'pine',
			h6 = 'foam',
		}
		-- or set all headings at once
		-- headings = 'subtle'
	},

	-- Change specific vim highlight groups
	-- https://github.com/rose-pine/neovim/wiki/Recipes
	highlight_groups = {
		ColorColumn = { bg = 'rose' },

		-- Blend colours against the "base" background
		CursorLine = { bg = 'foam', blend = 10 },
		StatusLine = { fg = 'love', bg = 'love', blend = 10 },
	}
})
--]]
function LineNumberColors()
    vim.api.nvim_set_hl(0, 'LineNrAbove', { fg='#51B3EC', bold=true })
    vim.api.nvim_set_hl(0, 'LineNr', { fg="#FFBF00", bold=true })
    vim.api.nvim_set_hl(0, 'LineNrBelow', { fg='#FB508F', bold=true })
end

LineNumberColors()

vim.cmd([[colorscheme catppuccin]])
--configurations for solarized theme
--local cb = require('colorbuddy.init')
--local Color = cb.Color
--local colors = cb.colors
--local Group = cb.Group
--local groups = cb.groups
--local styles = cb.styles

--Color.new('black', '#000000')
--Group.new('CursorLine', colors.none, colors.base03, styles.NONE, colors.base1)
--Group.new('CursorLineNr', colors.yellow, colors.black, styles.NONE, colors.base1)
--Group.new('Visual', colors.none, colors.base03, styles.reverse)

--local cError = groups.Error.fg
--local cInfo = groups.Information.fg
--local cWarn = groups.Warning.fg
--local cHint = groups.Hint.fg

--Group.new("DiagnosticVirtualTextError", cError, cError:dark():dark():dark():dark(), styles.NONE)
--Group.new("DiagnosticVirtualTextInfo", cInfo, cInfo:dark():dark():dark(), styles.NONE)
--Group.new("DiagnosticVirtualTextWarn", cWarn, cWarn:dark():dark():dark(), styles.NONE)
--Group.new("DiagnosticVirtualTextHint", cHint, cHint:dark():dark():dark(), styles.NONE)
--Group.new("DiagnosticUnderlineError", colors.none, colors.none, styles.undercurl, cError)
--Group.new("DiagnosticUnderlineWarn", colors.none, colors.none, styles.undercurl, cWarn)
--Group.new("DiagnosticUnderlineInfo", colors.none, colors.none, styles.undercurl, cInfo)
--Group.new("DiagnosticUnderlineHint", colors.none, colors.none, styles.undercurl, cHint)
