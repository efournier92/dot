return {
  -- Manual-only completion, like Vim: nothing pops up until you ask for it.
  -- LazyVim enables saghen/blink.cmp via the coding.blink extra and auto-shows
  -- the menu, docs, ghost text, and auto-brackets. Turn all of that off.
  --
  -- Invoke the menu yourself with <C-space>; native Ctrl-X modes still work.
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        -- master switch: never auto-open the menu
        menu = { auto_show = false },
        -- no floating doc window, inline ghost text, or auto-brackets
        documentation = { auto_show = false },
        ghost_text = { enabled = false },
        accept = { auto_brackets = { enabled = false } },
        -- close off every automatic trigger path
        trigger = {
          show_on_keyword = false,
          show_on_insert = false,
          show_on_trigger_character = false,
          show_on_accept_on_trigger_character = false,
          show_on_insert_on_trigger_character = false,
          show_on_backspace = false,
          show_on_backspace_in_keyword = false,
          show_on_backspace_after_accept = false,
          show_on_backspace_after_insert_enter = false,
        },
      },
      -- experimental signature help (disabled by default; explicit here)
      signature = { enabled = false },
      -- command-line: same -- no auto menu, no ghost text
      cmdline = {
        completion = {
          menu = { auto_show = false },
          ghost_text = { enabled = false },
        },
      },
    },
  },
}
