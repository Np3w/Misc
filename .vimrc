" Np3w's vim config

" Stuff
:set relativenumber
:set shiftround
:set wrap

" Try to remove weird latency issues
:set timeoutlen=1000
:set ttimeoutlen=0

" Move lines around
:nnoremap - ddp
:nnoremap _ ddkP

" Delete instead of cut
:nnoremap x "_1dl
:nnoremap <delete> "_dd

" Change case of current word
:inoremap <c-c> <esc>viw~i
:nnoremap <c-c> viw~

"nnoremap <c-b> 

" Status line
:set noruler
:set laststatus=2

:function MyStatusLine()
:	let left = bufname("%")
:	let w = winwidth(0)
:	let right = printf("L%d C%-4d", line('.'), col('.'))
:	let spacing = w - strchars(left) - strchars(right)
:	return "". left . repeat(" ", spacing) . right
:endfunction

:hi statusline ctermbg=white ctermfg=black
:set statusline=%!MyStatusLine()

