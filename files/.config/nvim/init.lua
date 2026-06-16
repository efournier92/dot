vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("user.file-reference-to-clipboard")
vim.cmd('colorscheme kanagawa')
