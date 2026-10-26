return {
  -- Vim has no inline type/parameter hints. LazyVim enables LSP inlay hints by
  -- default; turn them off so nothing is shown that wasn't asked for.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.inlay_hints = opts.inlay_hints or {}
      opts.inlay_hints.enabled = false
      return opts
    end,
  },
}
