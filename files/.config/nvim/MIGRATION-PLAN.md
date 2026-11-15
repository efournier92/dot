# Plan: LazyVim to a lean own config

Status: plan only, nothing built.
Verified against Neovim 0.12.6 and the installed plugins on 2026-11-14.

## Goal and usage profile

Usage is mostly reading files, LazyGit and fugitive, with language servers now and then.
Keep that working, drop everything else, and stop overriding a distro.

Evidence that the distro costs more than it gives:

1. `lua/plugins/disabled.lua` turns off 12 plugins.
1. Other files override LazyVim defaults: blink auto-show, inlay hints, telescope, dashboard, colorscheme, Java autoformat.
1. Every issue fixed on 2026-11-14 was a LazyVim default: 2-space Java indent, format on save, noice, the update checker.
1. On-demand LSP needed a `vim.lsp.start` override and a key replay that raced LazyVim's per-buffer keymaps.

## Decisions

| Topic | Decision | Why |
|---|---|---|
| Plugin manager | Keep lazy.nvim, drop the LazyVim layer | The fugitive, kanagawa, markdown and lazysql specs port unchanged. `lazy-lock.json` keeps working. `vim.pack` is new in 0.12 and buys nothing at this size. |
| Formatting | On demand only. `<leader>cf` (normal and visual) runs `vim.lsp.buf.format()` through the on-demand start wrapper. | Drops conform. Nothing changes on save. ruby_lsp formats with rubocop `-a`, the same as conform today. |
| Statusline | A. Trimmed default statusline string, no plugin | No LSP progress text. |
| Completion | Native `vim.lsp.completion`, manual only | Matches the current blink setup with everything turned off. |
| LSP start | On demand, native | No `vim.lsp.start` override. Servers are enabled only when asked. |

## Final plugin set (11)

| Plugin | Role |
|---|---|
| lazy.nvim | Plugin manager |
| kanagawa.nvim | Colorscheme |
| snacks.nvim | Picker, explorer, lazygit, terminal, bigfile, quickfile, notifier, input. Today's `snacks.lua` enables only the picker, since LazyVim turns on the rest. Add `enabled = true` for bigfile, quickfile, notifier and input. |
| gitsigns.nvim | Signs only. Today every gitsigns key comes from LazyVim. Port `]h`/`[h` and blame-line. Use a prefix other than `<leader>gh`, which `fugitive.lua` binds to diffget. |
| vim-fugitive | Existing diff and commit workflow |
| vim-markdown | Markdown syntax, as in Vim |
| lazysql | `<leader>db` |
| nvim-lspconfig | Server configs only (`lsp/*.lua`), nothing auto-enabled |
| mason.nvim | Installs jdtls, lua_ls, ruby-lsp, vtsls. Set `lazy = false`: PATH and `$MASON` (lombok jar) exist only after `mason.setup()` runs. |
| nvim-jdtls | `jdt://` library sources, extract refactors, organize imports |
| nvim-treesitter (`main`) | Parser installer only. Already on `main`. |

Plus mini.icons for picker and explorer icons (decided). Snacks notifier stays on (decided).

Dropped: LazyVim, blink.cmp, which-key, lualine, conform, mason-lspconfig, ts-comments, nvim-treesitter-textobjects, nvim-ts-autotag, mini.ai, trouble, grug-far, lazydev.

## Built-ins that replace dropped plugins (verified in 0.12.6 runtime)

| Need | Built-in | Where verified |
|---|---|---|
| Commenting, language-aware | `gc`, `gcc` | `runtime/lua/vim/_comment.lua` reads the treesitter language at the cursor |
| LSP keys | `grn` rename, `gra` code action, `grr` references, `gri` implementation, `grt` type definition, `gO` symbols, `K` hover, `<C-s>` signature | `runtime/lua/vim/_core/defaults.lua` |
| Diagnostics nav | `[d` `]d` `[D` `]D`, `<C-w>d` float | same file |
| Completion | `vim.lsp.completion.enable(true, id, buf, { autotrigger = false })` | `runtime/lua/vim/lsp/completion.lua` |
| Server config | `vim.lsp.config()`, `vim.lsp.enable()` | `runtime/lua/vim/lsp.lua` |

Not built in: `gd`. Map it to `Snacks.picker.lsp_definitions()` on attach.

## Layout

```
~/.config/nvim-lean/
  init.lua                  leader, require config.*, lazy setup
  lua/config/options.lua    curated options (below) + markdown treesitter guard
  lua/config/keymaps.lua    ported keys (below)
  lua/config/autocmds.lua   yank highlight, markdown syntax, treesitter start + foldexpr,
                            wrap/linebreak for markdown and gitcommit (spell optional),
                            checktime on FocusGained/TermClose/TermLeave (stale buffers after LazyGit),
                            restore last cursor position, q closes qf/help, auto-create parent dir on write
  lua/config/lsp.lua        on-demand start, LspAttach keys, completion, diagnostics
  lua/config/statusline.lua only if a custom statusline is chosen
  lua/plugins/*.lua         one spec per plugin, most copied as-is
  lua/user/file-reference-to-clipboard.lua   copied as-is
  ftplugin/java.lua         jdtls start (ported from plugins/java.lua)
  after/ftplugin/java.lua   shiftwidth 4, copied as-is
```

## Options to carry over

These are the LazyVim options that change behavior you would notice.
Everything else in LazyVim's `options.lua` is a default already or cosmetic.

`expandtab`, `shiftwidth=2`, `tabstop=2`, `shiftround`, `ignorecase`, `smartcase`, `signcolumn=yes`, `splitright`, `splitbelow`, `splitkeep=screen`, `scrolloff=4`, `sidescrolloff=8`, `cursorline`, `wrap=false`, `linebreak`, `confirm`, `virtualedit=block`, `foldlevel=99`, `laststatus=3`, `jumpoptions=view`, `updatetime=200`.
Folds: LazyVim uses treesitter `foldexpr` per buffer. Set it in the treesitter FileType autocmd, with `foldmethod=indent` as the fallback.
Plus your own: `clipboard=unnamedplus`, `swapfile=false`, `undofile=false`, `number`, `relativenumber=false`.
Plus `vim.g.java_ignore_markdown = 1` (the E28 fix), set at startup, not in the Java ftplugin.
Drop: `conceallevel=2` (your markdown autocmd already resets it), `list`, `timeoutlen=300` (only needed for which-key).

The markdown treesitter guard in today's `options.lua` must come along.
Neovim's own `runtime/ftplugin/markdown.lua` calls `vim.treesitter.start()`, not LazyVim.

## Keymaps to port

Decided set: `<C-h/j/k/l>` window nav, `<S-h>`/`<S-l>` buffers, `<leader>bd`, `<leader>cf`, `<leader>ca`, `<leader>cr`, `<leader>cd`.
Picker: `<leader><space>` smart (own), `<leader>ff` files, `<leader>/` grep, `<leader>fr` recent, `<leader>,` buffers, `<leader>e` explorer, `<leader>gg` lazygit, `<leader>sk` keymaps (replaces which-key for discovery).
`<leader>ff`, `<leader>/`, `<leader>e` and `<leader>gg` pass `cwd = Snacks.git.get_root()`.
Today they open at the git root via LazyVim's root detection. Plain Snacks calls would use the cwd, which is wrong in the multi-repo Savvy workspace.
Small LazyVim keys worth keeping: `<esc>` clears search highlight, `<leader>qq` quits all.
Dropped on purpose: `<C-s>` save, `<leader>wd`, `<leader><tab>d`. Re-add in phase 6 if missed.
Own keys copied as-is: `<leader>wt`, `<M-j>`/`<M-k>`, fugitive keys, `<leader>cy`, `<leader>db`.
LSP on attach: the same set the on-demand wrapper covers today: `gd`, `gr`, `gI`, `gy`, `gD`, `K`, `gK`, `gai`, `gao`, `<leader>ca`, `<leader>cA`, `<leader>cr`, `<leader>ss`, `<leader>sS`. Built-in `gr*` keys need nothing.
Java on jdtls attach: `<leader>co` organize imports, `<leader>cxv`/`cxc`/`cxm` extract variable, constant, method, `<leader>cgs` goto super. Today these come from LazyVim's java extra.

## On-demand LSP, native

1. Call `vim.lsp.config()` for lua_ls, ruby_lsp, vtsls at startup. Never call `vim.lsp.enable()` at startup.
1. `<leader>cL` sets `vim.g.lsp_on`, calls `vim.lsp.enable()` for those servers, and reruns FileType on the buffer.
1. `ftplugin/java.lua` calls `require("jdtls").start_or_attach()` only when `vim.g.lsp_on` is set.
1. One `LspAttach` autocmd sets `gd`/`gr`/`gI`/`gy`, enables completion, and turns off inlay hints.
1. Global `gd` etc. keep the poll-then-act wrapper, with the busy check and the references context.
   The keymap race disappears because our own `LspAttach` sets the buffer keys synchronously.
1. Rewrite `has_server` over `vim.lsp.config[name].filetypes`. Today it calls `LazyVim.opts()`, which does not exist without LazyVim.
1. Give lua_ls `workspace.library = { vim.env.VIMRUNTIME }`. Dropping lazydev otherwise flags `vim` as an undefined global when editing this config.

## Statusline options

Neovim 0.12's default `statusline` already shows file, flags, diagnostics count and position.
It also shows LSP progress via `vim.ui.progress_status()`, which would bring back the jdtls noise.

| Option | Shows | Cost |
|---|---|---|
| A. Trimmed default (recommended) | File, modified flag, git branch (`b:gitsigns_head`), diagnostics, line:col | One `statusline` string, about 3 lines. No plugin. |
| B. No statusline | Nothing. `<C-g>` shows file, `ruler` shows position | `laststatus=0`. Zero lines. Splits lose their file labels. |
| C. mini.statusline | Mode, branch, diagnostics, file, position | One small plugin |

## Java

Port `lua/plugins/java.lua` into `ftplugin/java.lua`, keeping:
the root via `gradlew`, the per-project workspace under `stdpath("cache")/jdtls`, the lombok agent, the JDK runtime settings, the lean JVM flags, and the Gradle test keys.

### Fast start: static Eclipse files instead of a Gradle sync (measured)

jdtls re-syncs all 12 Gradle projects on every start, one after another.
That sync is about 20 of the 22 seconds before `gd` answers.
Importing static Eclipse project files skips it.

| | Gradle sync (today) | Static Eclipse files |
|---|---|---|
| `gd` ready, warm | 22.4s | 3.1s |
| `gd` ready, cold | 22 to 29s | 3.8s |
| Errors in `CustodianCorrespondentSecretsCipher.java` | 0 | 0 |
| Library `gd` on `KmsClient` | works | works, opens `jdt://.../kms-2.40.8.jar/...` |
| Generating the files | none | 2.25s with a warm Gradle daemon |

How it works:

1. A one-line Gradle init script kept in the nvim config: `allprojects { apply plugin: "eclipse" }`.
   Nothing changes in the PVS repo. The generated files are already gitignored.
1. Before starting jdtls, `ftplugin/java.lua` runs `./gradlew --init-script <script> eclipse` when any `.classpath` is missing or older than `settings.gradle` or any `build.gradle`.
1. Start jdtls with `java.import.gradle.enabled = false`.
   This setting must go in `init_options.settings`, not only `settings`.
   nvim-jdtls never copies `settings` into `init_options` (`nvim-jdtls/lua/jdtls/setup.lua:413-416`), so jdtls ignores import settings sent the normal way.
1. The Buildship prefs cleanup goes away. No Gradle import means no pinned JDK path.

Caveats:

1. A jdtls Gradle sync overwrites the generated files with Buildship's own entries, and a later static import then sees no jars.
   Never mix the two modes on one checkout. Delete and regenerate if it happens.
1. Memory was 1.1GB warm in the experiment. That run may not have used the lean JVM flags (820MB with Gradle sync).
   Measure again in phase 5.
1. This also works on today's LazyVim setup, through `opts.jdtls` in `lua/plugins/java.lua`.
   It could ship before the migration.

## Phases, each with a check

Build in `~/.config/nvim-lean`, run with `NVIM_APPNAME=nvim-lean nvim`.

1. Skeleton: init, options, keymaps, autocmds, lazy.nvim, kanagawa, snacks, statusline.
   Check: headless start in a real terminal prints no errors. `<leader>ff`, `<leader>e`, `<leader>gg` work.
1. Git: gitsigns, fugitive spec, the lazygit `e` custom command (Gvdiffsplit via `$NVIM --remote-expr`).
   Check: `<leader>GG` and `<leader>GB` open the diff tab. `<M-j>` follows quickfix.
1. Reading extras: treesitter start per filetype minus markdown, vim-markdown, lazysql, file-reference key.
   Check: highlighting in java, ruby, tsx. Markdown keeps Vim syntax. No E28 on Java.
1. LSP: lspconfig, mason, `lua/config/lsp.lua`.
   Check: no server process after opening a file. `gd` cold jumps in TS (about 5s) and Ruby. `<leader>cf` formats.
1. Java: `ftplugin/java.lua`.
   Check: cold `gd` jumps in PVS within about 5s. `gd` on `KmsClient` opens a `jdt://` source. Touching a `build.gradle` triggers regeneration. `<leader>tt` runs. Measure jdtls RSS.
1. Daily-drive for a week with `NVIM_APPNAME=nvim-lean`. Note every missing key.
1. Switch: swap `~/.config/nvim` and `~/.config/nvim-lean`. Rollback is the same swap.

## Setup cost for the side-by-side data dir

`NVIM_APPNAME=nvim-lean` gets its own data, state and cache.

1. lazy.nvim reinstalls 11 plugins, about 50MB.
1. Symlink `~/.local/share/nvim-lean/mason` to the existing Mason dir to skip reinstalling servers.
1. Symlink `~/.local/share/nvim-lean/site/parser` to reuse the 26 installed parsers.
1. The jdtls cache is new, so the first Java start does a full import once.

## Risks

| Risk | Mitigation |
|---|---|
| Lua formatting changes: lua_ls formats with its own style, not stylua | Run `stylua` by hand when editing Lua, or keep a one-line `<leader>cf` override for lua |
| No formatter for shell scripts without conform | Run `shfmt -w %` by hand. Rare in this workflow. |
| You own plugin breaking changes (nvim-treesitter `main`, Mason) | 11 plugins pinned in `lazy-lock.json`. Update on purpose with `:Lazy update`. |
| A LazyVim key you use but did not list | Phase 6 daily-drive. `<leader>sk` lists what exists. |
| Snacks features LazyVim enabled are lost | Only picker, explorer, lazygit, terminal, bigfile, quickfile, notifier and input are re-enabled. Scroll animation, indent guides, scope and words are dropped on purpose. |

## Open decisions

None. Statusline A, mini.icons and snacks notifier were decided on 2026-11-14.
The Java fast start ships on the current LazyVim setup first. Phase 5 ports it.
