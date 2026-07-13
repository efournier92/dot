-- List Fugitive diffs in quickfix menu
function _G.fugitive_qf_clean()
  local qf = vim.fn.getqflist()
  for _, item in ipairs(qf) do
    if item.module and item.module ~= "" then
      item.module = item.module:gsub(".*:", "")
    end
  end
  vim.fn.setqflist(qf, "r")
end

-- Run `git commit` in a real terminal split (full-width, top of the tab)
function _G.fugitive_commit_split()
  vim.cmd("topleft terminal git commit")
  vim.cmd("startinsert")
end

-- Bind <leader>cc to fugitive_commit_split
function _G.fugitive_bind_commit_key()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    vim.keymap.set("n", "<leader>cc", "<cmd>lua _G.fugitive_commit_split()<CR>", {
      buffer = vim.api.nvim_win_get_buf(w),
      desc = "Commit (fugitive)",
    })
  end
end

-- Navigate the quickfix menu
function _G.fugitive_diff_nav(cmd)
  vim.cmd("silent! " .. cmd)
  local qf = vim.fn.getqflist({ idx = 0, context = 1 })
  local items = (qf.context or {}).items or {}
  local ctx = items[qf.idx]
  local diff = ctx and ctx.diff or {}
  if #diff == 0 then
    return
  end
  local companion = diff[#diff].filename
  local cur_win = vim.api.nvim_get_current_win()
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buftype = vim.bo[vim.api.nvim_win_get_buf(w)].buftype
    if w ~= cur_win and buftype ~= "quickfix" then
      vim.api.nvim_win_close(w, false)
    end
  end
  vim.cmd("leftabove vertical diffsplit " .. vim.fn.fnameescape(companion))
  _G.fugitive_bind_commit_key()
  vim.cmd("wincmd p")
end

return {
  "tpope/vim-fugitive",
  cmd = { "Git", "G", "Gvdiffsplit", "Gdiffsplit", "Gvdiff", "Gdiff", "Gedit", "Gread" },
  keys = {
    { "<leader>gG", "<cmd>tab Git<CR>", desc = "Fugitive Status" },
    {
      "<leader>GG",
      function()
        vim.cmd("tabnew")
        vim.cmd("Git difftool --cached")
        _G.fugitive_qf_clean()
        vim.cmd("leftabove Gvdiffsplit @")
        vim.cmd("botright copen")
        _G.fugitive_bind_commit_key()
      end,
      desc = "Staged changes diff (quickfix)",
    },
    {
      "<leader>GB",
      function()
        vim.cmd("tabnew")
        vim.cmd("Git difftool main...HEAD")
        _G.fugitive_qf_clean()
        vim.cmd("leftabove Gvdiffsplit main")
        vim.cmd("botright copen")
        _G.fugitive_bind_commit_key()
      end,
      desc = "Branch changes vs main diff (quickfix)",
    },
  },
  config = function()
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

        vim.keymap.set("n", "cc", _G.fugitive_commit_split, { buffer = bufnr, desc = "Commit" })
        vim.keymap.set(
          "n",
          "vv",
          "<Plug>fugitive:dv",
          { buffer = bufnr, remap = true, desc = "Vertical diff (alias of dv)" }
        )
        vim.keymap.set(
          "n",
          "hh",
          "<Plug>fugitive:dh",
          { buffer = bufnr, remap = true, desc = "Horizontal diff (alias of dh)" }
        )
      end,
    })
  end,
}
