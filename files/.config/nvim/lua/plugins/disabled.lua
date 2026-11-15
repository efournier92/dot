return {
  { "LazyVim/LazyVim", opts = { colorscheme = "kanagawa" } },
  { "folke/tokyonight.nvim", enabled = false },
  { "catppuccin/nvim", name = "catppuccin", enabled = false },
  { "folke/noice.nvim", enabled = false },
  { "akinsho/bufferline.nvim", enabled = false },
  { "nvim-mini/mini.pairs", enabled = false },
  { "rafamadriz/friendly-snippets", enabled = false },
  { "folke/persistence.nvim", enabled = false },
  { "folke/todo-comments.nvim", enabled = false },
  { "folke/flash.nvim", enabled = false },
  { "MunifTanjim/nui.nvim", enabled = false },
  { "nvim-mini/mini.ai", enabled = false },
  { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
  { "nvim-lua/plenary.nvim", enabled = false },
  -- LazyVim only configures a fish linter.
  { "mfussenegger/nvim-lint", enabled = false },
  -- Formatting is on demand through the language server (<leader>cf).
  { "stevearc/conform.nvim", enabled = false },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      local unused = { stylua = true, shfmt = true, ["erb-formatter"] = true, ["erb-lint"] = true }
      opts.ensure_installed = vim.tbl_filter(function(name)
        return not unused[name]
      end, opts.ensure_installed or {})
    end,
  },
}
