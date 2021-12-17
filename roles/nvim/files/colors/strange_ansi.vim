highlight clear
if exists("syntax_on") | syntax reset | endif

let g:colors_name = "strange_ansi"

highlight Bold                       cterm=bold gui=bold
highlight Debug                      ctermfg=Red guifg=Red
highlight Directory                  ctermfg=Magenta guifg=Magenta
highlight Error                      ctermfg=LightGray guifg=LightGray ctermbg=Red guibg=Red
highlight ErrorMsg                   ctermfg=Red guifg=Red ctermbg=LightGray guibg=LightGray
highlight Exception                  ctermfg=Red guifg=Red
highlight FoldColumn                 ctermfg=Cyan guifg=Cyan ctermbg=White guibg=White
highlight Folded                     ctermfg=Gray guifg=Gray ctermbg=White guibg=White
highlight IncSearch                  ctermfg=White guifg=White ctermbg=Yellow guibg=Yellow cterm=none gui=none
highlight Italic                     cterm=italic gui=italic
highlight Macro                      ctermfg=Red guifg=Red
highlight MatchParen                 ctermfg=LightGray guifg=LightGray ctermbg=Gray guibg=Gray
highlight ModeMsg                    ctermfg=Green guifg=Green
highlight MoreMsg                    ctermfg=Green guifg=Green
highlight Question                   ctermfg=Magenta guifg=Magenta
highlight Search                     ctermfg=Gray guifg=Gray ctermbg=Green guibg=Green
highlight SpecialKey                 ctermfg=Gray guifg=Gray
highlight TooLong                    ctermfg=Red guifg=Red
highlight Underlined                 ctermfg=Red guifg=Red
highlight Visual                     ctermbg=Gray guibg=Gray
highlight VisualNOS                  ctermfg=Red guifg=Red
highlight WarningMsg                 ctermfg=Red guifg=Red
highlight WildMenu                   ctermfg=Red guifg=Red
highlight Title                      ctermfg=Magenta guifg=Magenta cterm=none gui=none
highlight Cursor                     ctermfg=LightGray guifg=LightGray ctermbg=Black guibg=Black
highlight TermCursorNC               ctermfg=LightGray guifg=LightGray ctermbg=Black guibg=Black
highlight NonText                    ctermfg=Gray guifg=Gray
highlight Normal                     ctermfg=Black guifg=Black ctermbg=LightGray guibg=#f3f3f3
highlight LineNr                     ctermfg=Gray guifg=Gray ctermbg=White guibg=White
highlight SignColumn                 ctermfg=Gray guifg=Gray ctermbg=White guibg=White
highlight StatusLine                 ctermfg=Black guifg=Black ctermbg=Gray guibg=Gray cterm=none gui=none
highlight StatusLineNC               ctermfg=Gray guifg=Gray ctermbg=White guibg=White cterm=none gui=none
highlight VertSplit                  ctermfg=Gray guifg=Gray ctermbg=Gray guibg=Gray cterm=none gui=none
highlight ColorColumn                ctermbg=White guibg=White cterm=none gui=none
highlight CursorColumn               ctermbg=White guibg=White cterm=none gui=none
highlight CursorLine                 ctermbg=White guibg=White cterm=none gui=none
highlight CursorLineNr               ctermfg=Gray guifg=Gray ctermbg=White guibg=White
highlight PMenu                      ctermfg=Gray guifg=Gray ctermbg=White guibg=White cterm=none gui=none
highlight PMenuSel                   ctermfg=White guifg=White ctermbg=Gray guibg=Gray
highlight TabLine                    ctermfg=Gray guifg=Gray ctermbg=White guibg=White cterm=none gui=none
highlight TabLineFill                ctermfg=Gray guifg=Gray ctermbg=White guibg=White cterm=none gui=none
highlight TabLineSel                 ctermfg=Green guifg=Green ctermbg=White guibg=White cterm=none gui=none

" Standard syntax highlighting
highlight Boolean                    ctermfg=Yellow guifg=Yellow
highlight Character                  ctermfg=Red guifg=Red
highlight Comment                    ctermfg=Gray guifg=Gray guifg=Gray cterm=italic gui=italic
highlight Conditional                ctermfg=Magenta guifg=Magenta
highlight Constant                   ctermfg=Yellow guifg=Yellow
highlight Define                     ctermfg=Magenta guifg=Magenta cterm=none gui=none
highlight Delimiter                  ctermfg=Red guifg=Red
highlight Float                      ctermfg=Yellow guifg=Yellow
highlight Function                   ctermfg=Magenta guifg=Magenta
highlight Identifier                 ctermfg=Red guifg=Red cterm=none gui=none
highlight Include                    ctermfg=Magenta guifg=Magenta
highlight Keyword                    ctermfg=Magenta guifg=Magenta
highlight Label                      ctermfg=Green guifg=Green
highlight Number                     ctermfg=Yellow guifg=Yellow
highlight Operator                   ctermfg=Black guifg=Black cterm=none gui=none
highlight PreProc                    ctermfg=Green guifg=Green
highlight Repeat                     ctermfg=Green guifg=Green
highlight Special                    ctermfg=Cyan guifg=Cyan
highlight SpecialChar                ctermfg=Red guifg=Red
highlight Statement                  ctermfg=DarkRed guifg=DarkRed
highlight StorageClass               ctermfg=Green guifg=Green
highlight String                     ctermfg=Green guifg=Green
highlight Structure                  ctermfg=Magenta guifg=Magenta
highlight Tag                        ctermfg=Green guifg=Green
highlight Todo                       ctermfg=Green guifg=Green ctermbg=White guibg=White
highlight Type                       ctermfg=Green guifg=Green cterm=none gui=none
highlight Typedef                    ctermfg=Green guifg=Green

" C highlighting
highlight cOperator                  ctermfg=Cyan guifg=Cyan
highlight cPreCondit                 ctermfg=Magenta guifg=Magenta

" C# highlighting
highlight csClass                    ctermfg=Green guifg=Green
highlight csAttribute                ctermfg=Green guifg=Green
highlight csModifier                 ctermfg=Magenta guifg=Magenta
highlight csType                     ctermfg=Red guifg=Red
highlight csUnspecifiedStatement     ctermfg=Magenta guifg=Magenta
highlight csContextualStatement      ctermfg=Magenta guifg=Magenta
highlight csNewDecleration           ctermfg=Red guifg=Red

" CSS highlighting
highlight cssBraces                  ctermfg=Black guifg=Black
highlight cssClassName               ctermfg=Magenta guifg=Magenta
highlight cssColor                   ctermfg=Cyan guifg=Cyan

" Diff highlighting
highlight DiffAdd                    ctermfg=Green guifg=Green ctermbg=White guibg=White
highlight DiffChange                 ctermfg=Magenta guifg=Magenta ctermbg=White guibg=White
highlight DiffDelete                 ctermfg=Red guifg=Red ctermbg=White guibg=White
highlight DiffText                   ctermfg=Magenta guifg=Magenta ctermbg=White guibg=White
highlight DiffAdded                  ctermfg=Green guifg=Green ctermbg=LightGray guibg=LightGray
highlight DiffFile                   ctermfg=Red guifg=Red ctermbg=LightGray guibg=LightGray
highlight DiffNewFile                ctermfg=Green guifg=Green ctermbg=LightGray guibg=LightGray
highlight DiffLine                   ctermfg=Magenta guifg=Magenta ctermbg=LightGray guibg=LightGray
highlight DiffRemoved                ctermfg=Red guifg=Red ctermbg=LightGray guibg=LightGray

" Git highlighting
highlight gitCommitOverflow          ctermfg=Red guifg=Red
highlight gitCommitSummary           ctermfg=Green guifg=Green

" HTML highlighting
highlight htmlBold                   ctermfg=Green guifg=Green cterm=bold gui=bold
highlight htmlItalic                 ctermfg=Magenta guifg=Magenta cterm=italic gui=italic
highlight htmlEndTag                 ctermfg=Black guifg=Black
highlight htmlTag                    ctermfg=Black guifg=Black

" JavaScript highlighting
highlight javaScript                 ctermfg=Black guifg=Black
highlight javaScriptBraces           ctermfg=Black guifg=Black
highlight javaScriptNumber           ctermfg=Yellow guifg=Yellow

" Mail highlighting
highlight mailQuoted1                ctermfg=Green guifg=Green
highlight mailQuoted2                ctermfg=Green guifg=Green
highlight mailQuoted3                ctermfg=Magenta guifg=Magenta
highlight mailQuoted4                ctermfg=Cyan guifg=Cyan
highlight mailQuoted5                ctermfg=Magenta guifg=Magenta
highlight mailQuoted6                ctermfg=Green guifg=Green
highlight mailURL                    ctermfg=Magenta guifg=Magenta
highlight mailEmail                  ctermfg=Magenta guifg=Magenta

" Markdown highlighting
highlight markdownCode               ctermfg=Green guifg=Green
highlight markdownError              ctermfg=Black guifg=Black ctermbg=LightGray guibg=LightGray
highlight markdownCodeBlock          ctermfg=Green guifg=Green
highlight markdownHeadingDelimiter   ctermfg=Magenta guifg=Magenta

" NERDTree highlighting
highlight NERDTreeDirSlash           ctermfg=Magenta guifg=Magenta
highlight NERDTreeExecFile           ctermfg=Black guifg=Black

" PHP highlighting
highlight phpMemberSelector          ctermfg=Black guifg=Black
highlight phpComparison              ctermfg=Black guifg=Black
highlight phpParent                  ctermfg=Black guifg=Black

" Python highlighting
highlight pythonOperator             ctermfg=Magenta guifg=Magenta
highlight pythonRepeat               ctermfg=Magenta guifg=Magenta

" Ruby highlighting
highlight rubyAttribute              ctermfg=Magenta guifg=Magenta
highlight rubyConstant               ctermfg=Green guifg=Green
highlight rubyInterpolation          ctermfg=Green guifg=Green
highlight rubyInterpolationDelimiter ctermfg=Red guifg=Red
highlight rubyRegexp                 ctermfg=Cyan guifg=Cyan
highlight rubySymbol                 ctermfg=Green guifg=Green
highlight rubyStringDelimiter        ctermfg=Green guifg=Green

" SASS highlighting
highlight sassidChar                 ctermfg=Red guifg=Red
highlight sassClassChar              ctermfg=Yellow guifg=Yellow
highlight sassInclude                ctermfg=Magenta guifg=Magenta
highlight sassMixing                 ctermfg=Magenta guifg=Magenta
highlight sassMixinName              ctermfg=Magenta guifg=Magenta

" Signify highlighting
highlight SignifySignAdd             ctermfg=Green guifg=Green ctermbg=White guibg=White
highlight SignifySignChange          ctermfg=Magenta guifg=Magenta ctermbg=White guibg=White
highlight SignifySignDelete          ctermfg=Red guifg=Red ctermbg=White guibg=White

" Spelling highlighting
highlight SpellBad                   ctermbg=LightGray guibg=LightGray cterm=undercurl guisp=undercurl
highlight SpellLocal                 ctermbg=LightGray guibg=LightGray cterm=undercurl guisp=undercurl
highlight SpellCap                   ctermbg=LightGray guibg=LightGray cterm=undercurl guisp=undercurl
highlight SpellRare                  ctermbg=LightGray guibg=LightGray cterm=undercurl guisp=undercurl

" Custom Statusline hightlighting
highlight StatusLineNormal           ctermfg=LightGray guifg=LightGray ctermbg=Green guibg=Green
highlight StatusLineInsert           ctermfg=LightGray guifg=LightGray ctermbg=Red guibg=Red
highlight StatusLineVisual           ctermfg=LightGray guifg=LightGray ctermbg=Magenta guibg=Magenta
highlight StatusLineTerm             ctermfg=LightGray guifg=LightGray ctermbg=Gray guibg=Gray

" Popup menu highlighting
highlight PmenuSbar                  ctermbg=Gray guibg=Gray
highlight PmenuThumb                 ctermbg=LightGray guibg=LightGray

" Ignore/Conceal
highlight Ignore                     ctermfg=Black guifg=Black
highlight Conceal                    ctermfg=Magenta guifg=Magenta ctermbg=LightGray guibg=LightGray
