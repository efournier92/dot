" ============================================================================
" Kanagawa (Wave) colorscheme for Vim
" ------------------------------------------------------------------------
" Adapted from:
"   * https://github.com/rebelot/kanagawa.nvim   (palette, Wave theme)
"   * https://github.com/menisadi/kanagawa.vim  (Vim port, used as base)
"
" This file mirrors the following Neovim configuration in pure Vimscript:
"
"   require("kanagawa").setup({
"     commentStyle = { italic = true },
"     functionStyle = {},
"     keywordStyle = { italic = true },
"     statementStyle = { bold = true },
"     typeStyle = {},
"     transparent = false,
"     theme = "wave",
"     colors = { theme = { all = { ui = { bg_gutter = "none" } } } },
"     overrides = function(colors)
"       return {
"         Normal       = { bg = "#000000" },
"         NormalFloat  = { bg = "#000000" },
"         FloatBorder  = { bg = "#000000" },
"         CursorLine   = { bg = "#0d0c0c" },
"         ColorColumn  = { bg = "#0d0c0c" },
"         SignColumn   = { bg = "#000000" },
"         StatusLine   = { bg = "#000000", fg = colors.theme.ui.fg       }, " fujiWhite
"         StatusLineNC = { bg = "#000000", fg = colors.theme.ui.fg_dim   }, " oldWhite
"         WinSeparator = { bg = "#000000", fg = colors.theme.ui.nontext  }, " sumiInk6 — matches ~ and LineNr
"       }
"     end,
"   })
"
" Requires true-color (termguicolors) for accurate rendering.
" ============================================================================

if exists("syntax_on")
  syntax reset
endif

let g:colors_name = "kanagawa"

if has("termguicolors")
  set termguicolors
endif

set background=dark
hi clear

" ---------------------------------------------------------------------------
" Palette (Wave)
"   sumiInk0  #16161D   sumiInk1 #181820   sumiInk2 #1A1A22
"   sumiInk3  #1F1F28   sumiInk4 #2A2A37   sumiInk5 #363646
"   sumiInk6  #54546D
"   waveBlue1 #223249   waveBlue2 #2D4F67
"   fujiWhite #DCD7BA   oldWhite  #C8C093   fujiGray  #727169
"   oniViolet #957FB8   crystalBlue #7E9CD8 springViolet1 #938AA9
"   springBlue #7FB4CA  waveAqua2 #7AA89F   springGreen #98BB6C
"   boatYellow2 #C0A36E carpYellow #E6C384  sakuraPink #D27E99
"   waveRed   #E46876   surimiOrange #FFA066 samuraiRed #E82424
"   roninYellow #FF9E3B dragonBlue #658594
" ---------------------------------------------------------------------------

" --- Syntax -----------------------------------------------------------------
hi Boolean      gui=bold   term=bold   cterm=bold    guifg=#ffa066 guibg=NONE ctermfg=215 ctermbg=NONE
hi String       gui=NONE   term=NONE   cterm=NONE    guifg=#98bb6c guibg=NONE ctermfg=114 ctermbg=NONE
hi link Character String
hi Number       gui=NONE   term=NONE   cterm=NONE    guifg=#d27e99 guibg=NONE ctermfg=174 ctermbg=NONE
hi link Float Number
hi Constant     gui=NONE   term=NONE   cterm=NONE    guifg=#ffa066 guibg=NONE ctermfg=215 ctermbg=NONE
hi Identifier   gui=NONE   term=NONE   cterm=NONE    guifg=#e6c384 guibg=NONE ctermfg=223 ctermbg=NONE
hi Function     gui=NONE   term=NONE   cterm=NONE    guifg=#7e9cd8 guibg=NONE ctermfg=111 ctermbg=NONE
hi Statement    gui=bold   term=bold   cterm=bold    guifg=#957fb8 guibg=NONE ctermfg=141 ctermbg=NONE
hi Keyword      gui=italic term=italic cterm=italic  guifg=#957fb8 guibg=NONE ctermfg=141 ctermbg=NONE
hi Operator     gui=NONE   term=NONE   cterm=NONE    guifg=#c0a36e guibg=NONE ctermfg=143 ctermbg=NONE
hi Exception    gui=NONE   term=NONE   cterm=NONE    guifg=#e46876 guibg=NONE ctermfg=168 ctermbg=NONE
hi PreProc      gui=NONE   term=NONE   cterm=NONE    guifg=#e46876 guibg=NONE ctermfg=168 ctermbg=NONE
hi link Include  PreProc
hi link Define   PreProc
hi link Macro    PreProc
hi link PreCondit PreProc
hi Type         gui=NONE   term=NONE   cterm=NONE    guifg=#7aa89f guibg=NONE ctermfg=108 ctermbg=NONE
hi link StorageClass Type
hi link Structure  Type
hi link Typedef    Type
hi Special      gui=NONE   term=NONE   cterm=NONE    guifg=#7fb4ca guibg=NONE ctermfg=110 ctermbg=NONE
hi link SpecialChar   Special
hi link SpecialComment Special
hi link Tag           Special
hi Delimiter    gui=NONE   term=NONE   cterm=NONE    guifg=#9cabca guibg=NONE ctermfg=146 ctermbg=NONE
hi SpecialKey   gui=NONE   term=NONE   cterm=NONE    guifg=#938aa9 guibg=NONE ctermfg=103 ctermbg=NONE
hi link Debug   Special
hi link Label        Statement
hi link Conditional  Statement
hi link Repeat       Statement
hi Comment      gui=italic term=italic cterm=italic  guifg=#727169 guibg=NONE ctermfg=242 ctermbg=NONE
hi Conceal      gui=bold   term=bold   cterm=bold    guifg=#938aa9 guibg=NONE ctermfg=103 ctermbg=NONE

" --- Search -----------------------------------------------------------------
hi Search       gui=NONE   term=NONE   cterm=NONE    guifg=#dcd7ba guibg=#2d4f67 ctermfg=187 ctermbg=24
hi IncSearch    gui=NONE   term=NONE   cterm=NONE    guifg=#223249 guibg=#ff9e3b ctermfg=24  ctermbg=215
hi CurSearch    gui=bold   term=bold   cterm=bold    guifg=#dcd7ba guibg=#2d4f67 ctermfg=187 ctermbg=24
hi Substitute   gui=NONE   term=NONE   cterm=NONE    guifg=#dcd7ba guibg=#49443c ctermfg=187 ctermbg=238

" --- Visual / Selection ------------------------------------------------------
hi Visual       gui=NONE   term=NONE   cterm=NONE    guifg=NONE guibg=#223249 ctermfg=NONE ctermbg=24
hi link VisualNOS Visual

" --- Diff -------------------------------------------------------------------
hi DiffAdd      gui=NONE   term=NONE   cterm=NONE    guifg=NONE guibg=#2b3328 ctermfg=NONE ctermbg=235
hi DiffChange   gui=NONE   term=NONE   cterm=NONE    guifg=NONE guibg=#252535 ctermfg=NONE ctermbg=235
hi DiffDelete   gui=NONE   term=NONE   cterm=NONE    guifg=#c34043 guibg=#43242b ctermfg=131 ctermbg=235
hi DiffText     gui=NONE   term=NONE   cterm=NONE    guifg=NONE guibg=#49443c ctermfg=NONE ctermbg=238

" --- Folds ------------------------------------------------------------------
hi Folded       gui=NONE   term=NONE   cterm=NONE    guifg=#938aa9 guibg=#2a2a37 ctermfg=103 ctermbg=235

" --- Normal / Cursor / Gutter (true-black bg per user override) -------------
hi Normal       gui=NONE   term=NONE   cterm=NONE    guifg=#dcd7ba guibg=#000000 ctermfg=187 ctermbg=16
hi NormalFloat  gui=NONE   term=NONE   cterm=NONE    guifg=#dcd7ba guibg=#000000 ctermfg=187 ctermbg=16
hi FloatBorder  gui=NONE   term=NONE   cterm=NONE    guifg=#54546d guibg=#000000 ctermfg=240 ctermbg=16
hi Cursor       gui=NONE   term=NONE   cterm=NONE    guifg=#1f1f28 guibg=#dcd7ba ctermfg=234 ctermbg=187
hi link lCursor  Cursor
hi link CursorIM Cursor
hi CursorLine   gui=NONE   term=NONE   cterm=NONE    guifg=NONE guibg=#0d0c0c ctermfg=NONE ctermbg=16
hi link CursorColumn CursorLine
hi LineNr       gui=NONE   term=NONE   cterm=NONE    guifg=#54546d guibg=NONE ctermfg=240 ctermbg=NONE
hi link LineNrAbove LineNr
hi link LineNrBelow LineNr
hi CursorLineNr gui=bold   term=bold   cterm=bold    guifg=#ff9e3b guibg=#0d0c0c ctermfg=215 ctermbg=16
hi link CursorLineFold FoldColumn
hi link CursorLineSign SignColumn
hi FoldColumn   gui=NONE   term=NONE   cterm=NONE    guifg=#54546d guibg=NONE ctermfg=240 ctermbg=NONE
hi SignColumn   gui=NONE   term=NONE   cterm=NONE    guifg=#938aa9 guibg=#000000 ctermfg=103 ctermbg=16
hi ColorColumn  gui=NONE   term=NONE   cterm=NONE    guifg=NONE guibg=#0d0c0c ctermfg=NONE ctermbg=16
hi EndOfBuffer  gui=NONE   term=NONE   cterm=NONE    guifg=#54546d guibg=NONE ctermfg=240 ctermbg=NONE
hi NonText      gui=NONE   term=NONE   cterm=NONE    guifg=#54546d guibg=NONE ctermfg=240 ctermbg=NONE
hi Whitespace   gui=NONE   term=NONE   cterm=NONE    guifg=#54546d guibg=NONE ctermfg=240 ctermbg=NONE
hi QuickFixLine gui=NONE   term=NONE   cterm=NONE    guifg=NONE guibg=#0d0c0c ctermfg=NONE ctermbg=16

" --- Status / Tab lines -----------------------------------------------------
hi StatusLine       gui=NONE term=NONE cterm=NONE guifg=#dcd7ba guibg=#000000 ctermfg=187 ctermbg=16
hi StatusLineNC     gui=NONE term=NONE cterm=NONE guifg=#c8c093 guibg=#000000 ctermfg=143 ctermbg=16
hi link StatusLineTerm   StatusLine
hi link StatusLineTermNC StatusLineNC
" VertSplit ships with Vim's built-in default `gui=reverse cterm=reverse term=reverse`,
" which `:hi link` will NOT override. Clear those first, then link.
hi VertSplit     gui=NONE term=NONE cterm=NONE
hi WinSeparator  gui=NONE term=NONE cterm=NONE guifg=#54546d guibg=#000000 ctermfg=240 ctermbg=16
hi link VertSplit WinSeparator
hi TabLine          gui=NONE term=NONE cterm=NONE guifg=#938aa9 guibg=#000000 ctermfg=103 ctermbg=16
hi TabLineFill      gui=NONE term=NONE cterm=NONE guifg=NONE guibg=#000000 ctermfg=NONE ctermbg=16
hi TabLineSel       gui=NONE term=NONE cterm=NONE guifg=#c8c093 guibg=#0d0c0c ctermfg=143 ctermbg=16

" --- Messages ---------------------------------------------------------------
hi ErrorMsg      gui=NONE   term=NONE   cterm=NONE    guifg=#e82424 guibg=NONE ctermfg=160 ctermbg=NONE
hi WarningMsg    gui=NONE   term=NONE   cterm=NONE    guifg=#ff9e3b guibg=NONE ctermfg=215 ctermbg=NONE
hi ModeMsg       gui=bold   term=bold   cterm=bold    guifg=#ff9e3b guibg=NONE ctermfg=215 ctermbg=NONE
hi MoreMsg       gui=NONE   term=NONE   cterm=NONE    guifg=#658594 guibg=NONE ctermfg=66  ctermbg=NONE
hi link Question MoreMsg
hi Error         gui=NONE   term=NONE   cterm=NONE    guifg=#e82424 guibg=NONE ctermfg=160 ctermbg=NONE
hi MatchParen    gui=bold   term=bold   cterm=bold    guifg=#ff9e3b guibg=NONE ctermfg=215 ctermbg=NONE

" --- Completion menu (Pmenu) ------------------------------------------------
hi Pmenu         gui=NONE   term=NONE   cterm=NONE    guifg=#dcd7ba guibg=#223249 ctermfg=187 ctermbg=24
hi PmenuSel      gui=NONE   term=NONE   cterm=NONE    guifg=NONE guibg=#2d4f67 ctermfg=NONE ctermbg=24
hi PmenuSbar     gui=NONE   term=NONE   cterm=NONE    guifg=NONE guibg=#223249 ctermfg=NONE ctermbg=24
hi PmenuThumb    gui=NONE   term=NONE   cterm=NONE    guifg=NONE guibg=#2d4f67 ctermfg=NONE ctermbg=24
hi PmenuExtra    gui=NONE   term=NONE   cterm=NONE    guifg=#938aa9 guibg=#223249 ctermfg=103 ctermbg=24
hi PmenuExtraSel gui=NONE   term=NONE   cterm=NONE    guifg=#938aa9 guibg=#2d4f67 ctermfg=103 ctermbg=24
hi PmenuKind     gui=NONE   term=NONE   cterm=NONE    guifg=#c8c093 guibg=#223249 ctermfg=143 ctermbg=24
hi PmenuKindSel  gui=NONE   term=NONE   cterm=NONE    guifg=#c8c093 guibg=#2d4f67 ctermfg=143 ctermbg=24
hi PmenuMatch    gui=bold   term=bold   cterm=bold    guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE
hi PmenuMatchSel gui=bold   term=bold   cterm=bold    guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE
hi link WildMenu Pmenu

" --- Spelling ---------------------------------------------------------------
hi SpellBad  gui=undercurl term=undercurl cterm=undercurl guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE guisp=#e82424
hi SpellCap  gui=undercurl term=undercurl cterm=undercurl guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE guisp=#ff9e3b
hi SpellLocal gui=undercurl term=undercurl cterm=undercurl guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE guisp=#ff9e3b
hi SpellRare gui=undercurl term=undercurl cterm=undercurl guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE guisp=#ff9e3b

" --- Misc -------------------------------------------------------------------
hi Title       gui=bold      term=bold      cterm=bold      guifg=#7e9cd8 guibg=NONE ctermfg=111 ctermbg=NONE
hi Directory   gui=NONE      term=NONE      cterm=NONE      guifg=#7e9cd8 guibg=NONE ctermfg=111 ctermbg=NONE
hi Underlined  gui=underline term=underline cterm=underline guifg=#7fb4ca guibg=NONE ctermfg=110 ctermbg=NONE
hi Todo        gui=bold      term=bold      cterm=bold      guifg=#223249 guibg=#658594 ctermfg=24  ctermbg=66
hi link Ignore NonText
hi Added       gui=NONE      term=NONE      cterm=NONE      guifg=#98bb6c guibg=NONE ctermfg=114 ctermbg=NONE
hi Changed     gui=NONE      term=NONE      cterm=NONE      guifg=#7fb4ca guibg=NONE ctermfg=110 ctermbg=NONE
hi Removed     gui=NONE      term=NONE      cterm=NONE      guifg=#e46876 guibg=NONE ctermfg=168 ctermbg=NONE

" ============================================================================
" End of kanagawa (Wave) colorscheme
" ============================================================================
