-- Override default location
vim.env.XDG_CONFIG_HOME = vim.fn.expand("~/.config")

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Jumps happen instantly, as in Vim.
    scroll = { enabled = false },
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = { "build", ".gradle", "modules/*/bin" },
        },
        explorer = {
          hidden = true,
          ignored = true,
          exclude = { "build", ".gradle", "modules/*/bin" },
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
