" Np3w's vim/nvim config

" Neovim
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Stuff
:set relativenumber
:set shiftround
:set wrap

" Try to remove weird latency issues
:set timeoutlen=0
:set ttimeoutlen=0
:set lazyredraw

" Move lines around
:nnoremap - ddp
:nnoremap _ ddkP

" Delete instead of cut
:nnoremap x "_1dl
:nnoremap <delete> "_dd

" Change case of current word
":inoremap <c-c> <esc>viw~i
":nnoremap <c-c> viw~

:nnoremap <c-down>   }
:nnoremap <c-up>     {
:nnoremap <c-left>   b
:nnoremap <c-right>  e

:inoremap <c-down>     <esc>}a
:inoremap <c-up>       <esc>{a
:inoremap <c-left>     <esc>ba
:inoremap <c-right>    <esc>ea

:nnoremap <c-s>        :w<CR>
:inoremap <c-s>        <esc>:w<CR>a

" Shift based selection
:nnoremap <s-left>        v<left>
:nnoremap <s-right>       v<right>
:nnoremap <s-down>        v<down>
:nnoremap <s-up>          v<up>

:inoremap <s-down>     <esc>v<down>
:inoremap <s-up>       <esc>v<up>
:inoremap <s-left>     <esc>v<left>
:inoremap <s-right>    <esc>v<right>

:nnoremap <c-s-left>      v<c-left>
:nnoremap <c-s-right>     v<c-right>
:nnoremap <c-s-down>      v<c-down>
:nnoremap <c-s-up>        v<c-up>

:vnoremap <s-left>        <left>
:vnoremap <s-right>       <right>
:vnoremap <s-down>        <down>
:vnoremap <s-up>          <up>

:vnoremap <c-s-down>      }
:vnoremap <c-s-up>        {
:vnoremap <c-s-left>      b
:vnoremap <c-s-right>     e

:vnoremap <c-down>        }
:vnoremap <c-up>          {
:vnoremap <c-left>        b
:vnoremap <c-right>       e

:inoremap <c-backspace>   <esc>vbda

" ctrl-c copies
:vnoremap <c-c>           y

:nnoremap <c-tab> :tabnext<enter>
:nnoremap <c-n> :tabnext<enter>

" insert newline without going into insert mode
:nnoremap <c-o> o<esc>k
:nnoremap <c-s-o> O<esc>j

" Exit terminal mode shortcut
:if has('nvim')
:	tnoremap <esc> <C-\><C-n><C-w>k
:endif

" Project code
:function! BuildProject()
    :!./build.sh
:endfunction

:function! RunProject()
    :!./run.sh
:endfunction

:nnoremap <F6> :call RunProject()<enter>
:nnoremap <F4> :call BuildProject()<enter>
:nnoremap <c-b> :call BuildProject()<enter>

" Use clipboard by default
:set clipboard=unnamed,unnamedplus

" Status line
:set ruler
:set laststatus=2

:function! SyntaxItem()
  :return synIDattr(synID(line("."),col("."),1),"name")
:endfunction

:function! MyStatusLine()
    :if &mod
        :let modifier = "*"
    :else
        :let modifier = " "
    :endif
    :let line_num = 1
    :let n = 0
    :while line_num <= line('$')
        :let n = n + len(split(getline(line_num)))
        :let line_num = line_num + 1
    :endwhile
    :let word_count = printf("WordCount: %d", n)

    :let left = printf("%s [%s]", bufname("%"), modifier)

    :let w = winwidth(0)
    :let line_num = line('.')
    :let col_num = col('.')

    :let offset = line2byte(line_num) + col_num - 2
    :let right = printf("L%d C%-4d (%06d)", line_num, col_num, offset)

	:let middle = printf("%s", word_count)

    :let spacing1 = (w / 2) - strchars(left) - (strchars(middle) / 2)
	:let spacing2 = w - strchars(left) - spacing1 - strchars(middle) - strchars(right)

    :return "" . left . repeat(" ", spacing1) . middle . repeat(" ", spacing2) . right
:endfunction

:hi statusline ctermbg=white ctermfg=black
:set statusline=%!MyStatusLine()

" Tab settings
:set tabstop=4
:set shiftwidth=4
:set softtabstop=0
:set expandtab
:set smarttab
:set list
:set lcs=tab:\ \

" Let vim handle mouse input
:se mouse+=a

" ------------ "
" Setup colors "
" ------------ "

" Enable 24 bit colors
:if has('nvim')
:   set termguicolors
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

:if 0
" Another colorscheme
:if 0
:hi Normal guibg=#0c2000 guifg=#c0c900
:else
:hi Normal guibg=#0c2a60 guifg=#e6ec00
:endif

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

:if 0
" A nice colorscheme
:colorscheme morning
:endif
:colorscheme evening


:syntax enable




" Set gui font
set guifont=Liberation\ Mono\ 10





