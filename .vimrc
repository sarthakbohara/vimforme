syntax on
set number
set breakindent
inoremap ( ()<Left>
inoremap { {}<Left>
inoremap [ []<Left>
inoremap " ""<Left>
filetype plugin indent on
set autoindent
set smartindent
set cpoptions+=I
set ignorecase
set smartcase
inoremap <expr> <CR> getline('.')[col('.')-2] == '{' && getline('.')[col('.')-1] == '}' ? "\<CR>\<CR><Esc>O" : "\<CR>"
set noerrorbells
set novisualbell
inoremap <expr> ' getline('.')[col('.')-1] ==# '\s' ? "''\<Left>" : "'"
set foldmethod=manual
set foldlevelstart=99
highlight Folded ctermbg=NONE guibg=NONE
inoremap qq <Esc>
autocmd FileType * setlocal formatoptions-=r formatoptions-=o

