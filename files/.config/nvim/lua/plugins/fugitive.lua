return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G" },
  keys = {
    { "<leader>gG", "<cmd>tab Git<CR>", desc = "Fugitive Status" },
  },
  config = function()
    vim.keymap.set("n", "<Leader>gd", "<cmd>Gvdiff<CR>", { silent = true, desc = "Open vertical diff" })
    vim.keymap.set("n", "<Leader>gm", "<cmd>Gvdiffsplit!<CR>", { silent = true, desc = "Open merge tool" })
    vim.keymap.set("n", "<Leader>gh", "<cmd>diffget //2<CR>", { silent = true, desc = "Take left change" })
    vim.keymap.set("n", "<Leader>gl", "<cmd>diffget //3<CR>", { silent = true, desc = "Take right change" })
    vim.keymap.set("n", "<Leader>gp", "<cmd>G push<CR>", { silent = true, desc = "Push commits" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "fugitive",
      callback = function()
        local bufnr = vim.api.nvim_get_current_buf()

        vim.keymap.set("n", "<CR>", function()
          local file_path = vim.fn["fugitive#FilePath"]()

          if file_path and file_path ~= "" then
            vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(file_path))
            vim.cmd("Gdiffsplit")
          else
            vim.notify("No valid file selected under cursor", vim.log.levels.WARN)
          end
        end, { buffer = bufnr, desc = "Open file diff" })
      end,
    })
  end,
}
