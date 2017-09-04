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

:nnoremap <c-down>   }
:nnoremap <c-up>     {
:nnoremap <c-left>   b
:nnoremap <c-right>  e

:inoremap <c-down>     <esc>}a
:inoremap <c-up>       <esc>{a
:inoremap <c-left>     <esc>ba
:inoremap <c-right>    <esc>ea

:nnoremap <c-s>   :w<CR>
:inoremap <c-s>   <esc>:w<CR>a

" Shift based selection
:nnoremap <s-left>      v<left>
:nnoremap <s-right>     v<right>
:nnoremap <s-down>      v<down>
:nnoremap <s-up>        v<up>

:nnoremap <c-s-left>      v<c-left>
:nnoremap <c-s-right>     v<c-right>
:nnoremap <c-s-down>      v<c-down>
:nnoremap <c-s-up>        v<c-up>

:vnoremap <s-left>      <left>
:vnoremap <s-right>     <right>
:vnoremap <s-down>      <down>
:vnoremap <s-up>        <up>

:vnoremap <c-s-down>   }
:vnoremap <c-s-up>     {
:vnoremap <c-s-left>   b
:vnoremap <c-s-right>  e

:vnoremap <c-down>   }
:vnoremap <c-up>     {
:vnoremap <c-left>   b
:vnoremap <c-right>  e

:nnoremap <c-n> :tabnext<enter>

" Exit terminal mode shortcut
:if has('nvim')
:	tnoremap <esc> <C-\><C-n><C-w>k
:endif

" Build project
:function! BuildProject()
	:!./build.sh
:endfunction

:nnoremap <c-b> :call BuildProject()<enter>

" Status line
:set ruler
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

" ------------ "
" Setup colors "
" ------------ "

" Enable 24 bit colors
:if has('nvim')
:	set termguicolors
:endif

" Does something
:hi clear

:set background=dark

:hi SpecialKey ctermfg=gray ctermfg=gray guifg=#444444

:if 0
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
:endif

:if 1
:hi Normal guibg=#0c2000 guifg=#c0c900
:hi LineNr guibg=#0c2000 guifg=#c0c900
:hi CursorLineNr guibg=#2b303b guifg=#d2d7e0
:hi Type guifg=#40c0ff
:hi Comment ctermfg=LightGray guifg=#00f000
:hi Cursor guibg=#00ee00 guifg=#000000
:hi lCursor guibg=#d2d7e0
:hi String guifg=#c08020
:hi Constant guifg=#c08020
:hi Identifier guifg=#c0c900
:hi Statement guifg=#a04000
:hi PreProc ctermfg=LightGray guifg=#c0c900

:hi cFormat guifg=#ff3e2e

:hi! link cType Type
:hi! link cCppString String
:endif


:syntax enable



