-- pyright does not find a project venv on its own.
-- savvy-breaker keeps its venv under .work/venv.
local VENV_DIRS = { ".venv", "venv", ".work/venv" }

local function venv_python(root)
  for _, dir in ipairs(VENV_DIRS) do
    local python = vim.fs.joinpath(root, dir, "bin", "python")
    if vim.uv.fs_stat(python) then
      return python
    end
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers.pyright = opts.servers.pyright or {}
      opts.servers.pyright.on_init = function(client)
        local python = client.root_dir and venv_python(client.root_dir)
        if not python then
          return
        end
        client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
          python = { pythonPath = python },
        })
        client:notify("workspace/didChangeConfiguration", { settings = nil })
      end
    end,
  },
}
