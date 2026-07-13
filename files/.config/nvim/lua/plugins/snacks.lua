-- Override default location
vim.env.XDG_CONFIG_HOME = vim.fn.expand("~/.config")

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true,
          ignored = true,
        },
        explorer = {
          hidden = true,
          ignored = true,
        },
      },
    },
    dashboard = {
      enabled = false,
    },
    lazygit = {
      -- Open 'edit' in a Neovim session buffer
      configure = true,
    },
    styles = {
      lazygit = {
        -- Display LazyGit window with no margins
        width = 0,
        height = 0,
      },
    },
  },
  keys = {
    {
      "<leader><space>",
      function()
        Snacks.picker.smart()
      end,
      desc = "Smart Find",
    },
  },
}
