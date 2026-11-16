-- Language servers start only on demand, since nvim is mostly for reading.
-- jdtls and tsserver each hold about 1GB once started.
-- Core vim.lsp.enable and nvim-jdtls both start servers via vim.lsp.start.
local lsp_start = vim.lsp.start
vim.lsp.start = function(...)
  if vim.g.lsp_on then
    return lsp_start(...)
  end
end

local function start_lsp()
  vim.g.lsp_on = true
  vim.api.nvim_exec_autocmds("FileType", { buffer = 0, modeline = false })
end

local function has_server(buf)
  local ft = vim.bo[buf].filetype
  if ft == "java" then
    return true
  end
  for name in pairs(LazyVim.opts("nvim-lspconfig").servers or {}) do
    local config = name ~= "*" and vim.lsp.config[name]
    if config and vim.tbl_contains(config.filetypes or {}, ft) then
      return true
    end
  end
  return false
end

local SYMBOLS = "textDocument/documentSymbol"

-- LazyVim maps these keys per buffer once a server attaches.
-- These global fallbacks start the server, wait, then replay the key.
-- jdtls answers requests empty until its Gradle import finishes.
-- So poll with `probe` until it answers, and give up if the cursor moves.
local function on_demand(lhs, probe)
  local function native()
    vim.api.nvim_feedkeys(vim.keycode(lhs), "n", false)
  end
  return function()
    local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
    -- Attached but no buffer map means the server lacks this capability.
    if #vim.lsp.get_clients({ bufnr = buf }) > 0 or not has_server(buf) then
      return native()
    end
    local pos = vim.api.nvim_win_get_cursor(win)
    local deadline = vim.uv.now() + 120000
    local function try()
      local moved = vim.api.nvim_get_current_buf() ~= buf
        or not vim.deep_equal(vim.api.nvim_win_get_cursor(win), pos)
      if moved then
        return
      end
      if vim.uv.now() > deadline then
        return vim.notify("Language server found nothing", vim.log.levels.WARN)
      end
      local client = vim.lsp.get_clients({ bufnr = buf, method = probe })[1]
      if not client then
        return vim.defer_fn(try, 1000)
      end
      local params = probe == SYMBOLS
          and { textDocument = vim.lsp.util.make_text_document_params(buf) }
        or vim.lsp.util.make_position_params(win, client.offset_encoding)
      if probe == "textDocument/references" then
        params.context = { includeDeclaration = true }
      end
      -- LazyVim adds the buffer map shortly after the server first answers.
      local function replay(tries)
        local map = vim.fn.maparg(lhs, "n", false, true)
        if map.buffer == 1 and map.callback then
          return map.callback()
        end
        if map.buffer == 1 or tries >= 30 then
          return vim.api.nvim_feedkeys(vim.keycode(lhs), "m", false)
        end
        vim.defer_fn(function()
          replay(tries + 1)
        end, 100)
      end
      -- vtsls answers once early, then returns nothing until loading finishes.
      client:request(probe, params, function(_, result)
        local busy = not vim.tbl_isempty(client.progress.pending)
        if result and not vim.tbl_isempty(result) and not busy then
          replay(0)
        else
          vim.defer_fn(try, 2000)
        end
      end, buf)
    end
    vim.notify("Starting language server")
    start_lsp()
    try()
  end
end

local lazy_keys = {
  { "<leader>cL", start_lsp, desc = "Start LSP (this session)" },
}
for _, k in ipairs({
  { "gd", "textDocument/definition", "Goto Definition" },
  { "gr", "textDocument/references", "References" },
  { "gI", "textDocument/implementation", "Goto Implementation" },
  { "gy", "textDocument/typeDefinition", "Goto T[y]pe Definition" },
  { "gD", "textDocument/declaration", "Goto Declaration" },
  { "K", "textDocument/hover", "Hover" },
  { "gai", "textDocument/prepareCallHierarchy", "C[a]lls Incoming" },
  { "gao", "textDocument/prepareCallHierarchy", "C[a]lls Outgoing" },
  { "gK", SYMBOLS, "Signature Help" },
  { "<leader>ca", SYMBOLS, "Code Action" },
  { "<leader>cA", SYMBOLS, "Source Action" },
  { "<leader>cr", SYMBOLS, "Rename" },
  { "<leader>co", SYMBOLS, "Organize Imports" },
  { "<leader>sy", SYMBOLS, "LSP Symbols" },
  { "<leader>sS", SYMBOLS, "LSP Workspace Symbols" },
}) do
  local lhs, probe, desc = k[1], k[2], k[3]
  table.insert(lazy_keys, {
    lhs,
    on_demand(lhs, probe),
    desc = desc .. " (starts LSP)",
    nowait = lhs == "gr",
  })
end

return {
  -- Vim has no inline type/parameter hints. LazyVim enables LSP inlay hints by
  -- default; turn them off so nothing is shown that wasn't asked for.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.inlay_hints = opts.inlay_hints or {}
      opts.inlay_hints.enabled = false
      -- ruby_lsp already formats and lints with the project's own rubocop.
      opts.servers.rubocop = { enabled = false }
      -- <leader>ss is Smart Find, so LSP Symbols moves to <leader>sy.
      local keys = opts.servers["*"].keys
      table.insert(keys, { "<leader>ss", false })
      table.insert(keys, {
        "<leader>sy",
        function()
          Snacks.picker.lsp_symbols({ filter = LazyVim.config.kind_filter })
        end,
        desc = "LSP Symbols",
        has = "documentSymbol",
      })
      return opts
    end,
    keys = lazy_keys,
  },
}
