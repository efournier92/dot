vim.keymap.set({ "n", "v" }, "<leader>cy", function()
  local file = vim.fn.expand("%:.") -- Get relative path
  local ref = "@" .. file

  if vim.fn.mode() ~= "n" then
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    -- Swap if selection was made bottom-to-top
    if start_line > end_line then start_line, end_line = end_line, start_line end

    if start_line == end_line then
      ref = ref .. ":" .. start_line
    else
      ref = ref .. ":" .. start_line .. "-" .. end_line
    end
  end

  vim.fn.setreg("+", ref) -- Copy to system clipboard
  vim.notify("Copied: " .. ref)
end, { desc = "Copy AI-friendly file reference" })

