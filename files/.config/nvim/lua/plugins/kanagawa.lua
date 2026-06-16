return {
  "rebelot/kanagawa.nvim",
  lazy = false,    -- Load this immediately on startup
  priority = 1000, -- Ensure it loads before other plugins
  config = function()
    require("kanagawa").setup({
      compile = false,
      undercurl = true,
      commentStyle = { italic = true },
      functionStyle = {},
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = false,
      theme = "wave", -- Use the Wave variant
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none", -- Transparent line number gutter
            },
          },
        },
      },
      overrides = function(colors)
        return {
          -- The "True Black" core
          Normal = { bg = "#000000" },
          NormalFloat = { bg = "#000000" },
          FloatBorder = { bg = "#000000" },

          -- Floating Windows (Telescope, LSP Hover, etc.)
          TelescopeNormal = { bg = "#000000" },
          TelescopeBorder = { bg = "#000000" },

          -- UI Elements
          CursorLine = { bg = "#0d0c0c" }, -- Slightly off-black so you can find your cursor
          ColorColumn = { bg = "#0d0c0c" },
          SignColumn = { bg = "#000000" },

          -- Statusline and Borders
          StatusLine = { bg = "#000000", fg = colors.theme.ui.fg },
          StatusLineNC = { bg = "#000000", fg = colors.theme.ui.fg_dim },
          WinSeparator = { fg = colors.theme.ui.bg_p2, bg = "#000000" },
        }
      end,
    })
  end,
}
