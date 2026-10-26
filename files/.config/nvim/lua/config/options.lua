-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.undofile = false
vim.opt.number = true
vim.opt.relativenumber = false

-- Markdown: use the vim-markdown plugin's Vim `syntax`, not treesitter.
-- LazyVim/Neovim 0.12 starts treesitter highlighting for markdown, after which
-- Vim skips the syntax file (see the `b:ts_highlight` flag in syntax.vim), so
-- the plugin's syntax never applies. Block treesitter highlighting on markdown
-- buffers; the FileType autocmd in autocmds.lua enables the syntax.
local ts_start = vim.treesitter.start
vim.treesitter.start = function(bufnr, lang)
  if vim.bo[bufnr or 0].filetype == "markdown" then
    return
  end
  -- Guard: if upstream renames vim.treesitter.start, degrade instead of erroring.
  if not ts_start then
    return
  end
  return ts_start(bufnr, lang)
end
