local opt = vim.opt -- for conciseness
opt.mouse = "a"
opt.scroll = 1
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.foldmethod = "indent"  -- or "syntax" depending on your preference
opt.foldlevelstart = 99
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
opt.cmdheight = 2
opt.guifont = "Monolisa Engineering:h14"
opt.linespace = 2
opt.list = true
opt.listchars = { eol = '↲', tab = '▸ ', trail = '·', extends = '>', precedes = '<' }


-- line numbers
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- line wrapping
opt.wrap = false

-- search settings
--
opt.ignorecase = true
opt.smartcase = true

-- cursor line
opt.cursorline = true

--appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- backspace
opt.backspace = "indent,eol,start"

-- clipboard
opt.clipboard:append("unnamedplus")

-- split windows
opt.splitright = true
opt.splitbelow = true

opt.iskeyword:append("-")
opt.clipboard = "unnamedplus"
