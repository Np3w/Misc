" Np3w's vim config

let s:editor_root=expand("~/.config/nvim")

let &rtp = &rtp . ',' . s:editor_root . '/bundle/Vundle.vim'

filetype off

call vundle#rc(s:editor_root . '/bundle/') 

Plugin 'VundleVim/Vundle.vim'

Plugin 'ctrlpvim/ctrlp.vim'
let g:ctrlp_map = '<c-b>'

Plugin 'scrooloose/nerdtree'
Plugin 'bling/vim-airline'

" Colorscheme
syntax enable
set background=dark
Plugin 'flazz/vim-colorschemes'
colorscheme Benokai

set number

set colorcolumn=110
highlight ColorColumn ctermbg=darkgray
let &path.='src/include'
