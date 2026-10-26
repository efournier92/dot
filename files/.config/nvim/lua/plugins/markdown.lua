return {
  -- GitHub-flavored markdown syntax -- the same plugin used in regular vim
  -- (~/.vimrc). Pure VimL, so it works as-is in Neovim. It keeps the emphasis
  -- markers (*, _, `) visible and styles the text between them, because its
  -- conceal feature (g:markdown_enable_conceal) is off by default.
  --
  -- Loaded eagerly so its `syntax/markdown.vim` is on the 'runtimepath' before
  -- a markdown buffer sources syntax. Treesitter highlighting for markdown is
  -- blocked in lua/config/options.lua so it cannot override this syntax.
  {
    "gabrielelana/vim-markdown",
    lazy = false,
    init = function()
      vim.g.markdown_enable_input_abbreviations = 0
      vim.g.markdown_mapping_switch_status = "<Leader>m"
    end,
  },
}
