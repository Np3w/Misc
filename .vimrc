" Np3w's vim config

" Neovim
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Stuff
:set relativenumber
:set shiftround
:set wrap

" Try to remove weird latency issues
:set timeoutlen=1000
:set ttimeoutlen=0
:set lazyredraw

" Move lines around
:nnoremap - ddp
:nnoremap _ ddkP

" Delete instead of cut
:nnoremap x "_1dl
:nnoremap <delete> "_dd

" Change case of current word
:inoremap <c-c> <esc>viw~i
:nnoremap <c-c> viw~

:nnoremap <c-n> :tabnext<enter>

" Exit terminal mode shortcut
:tnoremap <esc> <C-\><C-n><C-w>k

" Build project
:function! BuildProject()
	:!./build.sh
:endfunction

:nnoremap <c-b> :call BuildProject()<enter>

" Status line
:set noruler
:set laststatus=2

:function! SyntaxItem()
  :return synIDattr(synID(line("."),col("."),1),"name")
:endfunction

:function! MyStatusLine()
	:let left = bufname("%")
	:let w = winwidth(0)
	:let line_num = line('.')
	:let col_num = col('.')
	:let offset = line2byte(line_num) + col_num - 2
	:let right = printf("L%d C%-4d (%06d)", line_num, col_num, offset)
	:let spacing = w - strchars(left) - strchars(right)
	:return "". left . repeat(" ", spacing) . right
:endfunction

:hi statusline ctermbg=white ctermfg=black
:set statusline=%!MyStatusLine()

" Tab settings
:set tabstop=2
:set shiftwidth=2
:set list
:set listchars=tab:\|\ ,extends:›,precedes:‹,nbsp:·,trail:·
"					hello

" Setup colors

" Enable 24 bit colors
:set termguicolors

" Does something
:hi clear

:set background=dark

:hi SpecialKey ctermfg=gray ctermfg=gray guifg=#444444

" Note: Based on GingerBill's Iridis colour scheme
:hi Normal guibg=#2b303b guifg=#d2d7e0
:hi LineNr guibg=#2b303b guifg=#d2d7e0
:hi CursorLineNr guibg=#2b303b guifg=#d2d7e0
:hi Type guifg=#40c0ff
:hi Comment ctermfg=LightGray guifg=#6e7a94
:hi Cursor guibg=#d2d7e0
:hi lCursor guibg=#d2d7e0
:hi String guifg=#b0ff22
:hi Constant guifg=#ae81ff
:hi Identifier guifg=#d2d7e0
:hi Statement guifg=#ff3848
:hi PreProc ctermfg=LightGray guifg=#6e7a94

:hi cFormat guifg=#ff3e2e

:hi! link cType Type
:hi! link cCppString String

" Keywords guifg=#ff3848

:syntax enable



