-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Markdown: use the vim-markdown plugin's Vim `syntax` (like regular vim),
-- not treesitter. LazyVim/Neovim 0.12 leaves `'syntax'` unset, so syntax files
-- never load on their own -- set it here. Treesitter highlighting for markdown
-- is blocked in lua/config/options.lua.
--
-- conceallevel is reset because LazyVim sets a global `conceallevel = 2`, which
-- would conceal emphasis/link markup. We want the markers kept visible.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.cmd("setlocal syntax=markdown")
    vim.opt_local.conceallevel = 0
    vim.opt_local.concealcursor = ""
  end,
})
