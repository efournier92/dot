--return {
--  "kdheepak/lazygit.nvim",
--  dependencies = {
--    "nvim-lua/plenary.nvim"
--  },
--  init = function()
--    vim.g.lazygit_floating_window_scaling_factor = 1.0
--  end,
--  config = function ()
--    vim.env.EDITOR = "nvim"
--  end,
--  keys = {
--    { "<leader>gg", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit (current file)" },
--    { "<leader>gG", "<cmd>LazyGit<cr>", desc = "LazyGit" },
--  },
--}
-- lazygit defaults to ~/Library/Application Support/lazygit on macOS, but
-- respects XDG_CONFIG_HOME if set. Point it at ~/.config so config.yml
-- (with our custom commands) lives alongside the rest of this repo.
-- Scoped to this nvim process and anything it spawns (e.g. :terminal),
-- not the user's shell environment.
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
      enabled = false
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
    -- Use "smart" picker by default
    { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find" },
  },
}
