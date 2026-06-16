return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      -- Remove the "LazyVim" icon/text from the statusline components
      opts.sections.lualine_y = { "progress" }
      opts.sections.lualine_z = { "location" }
    end,
  },
}
