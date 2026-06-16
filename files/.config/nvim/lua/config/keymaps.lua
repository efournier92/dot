vim.keymap.set("n", "<leader>wt", "<cmd>tabnew<cr>", { desc = "New Tab" })
-- vim.keymap set("n", "<C-d>", "<C-d>zz"),
-- vim.keymap set("n", "<C-u>", "<C-u>zz"),

--"<leader>ds" {fuzzy find over document symbols}

-- Navigate the quickfix menu
vim.keymap.set('n', '<M-j>', ':silent! cnext<CR>')
vim.keymap.set('n', '<M-k>', ':silent! cprev<CR>')
-- vim.keymap.set('n', '<leader>F', require('telescope.builtin').live_grep, { desc = 'Telescope live grep' })
-- vim.keymap.set('n', '<leader>M', require('telescope.builtin').marks, { desc = 'Telescope Marks' })

