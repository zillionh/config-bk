if ! exists("g:sco_include_key_mappings")
    finish
endif

vnoremap <buffer> w :Wrap<CR>
vnoremap <buffer> a :AllignRange<CR>
vnoremap <buffer> o :MultiOpen<CR>

nnoremap <buffer> <CR> :Enter<CR>
nnoremap <buffer> <C-CR> :ForceEnter<CR>
nnoremap <buffer> <C-i>p :Preview<CR>
nnoremap <buffer> <C-i>a :Allign<CR>

nnoremap <C-i>g :SCOGlobal expand('<cword>')<CR>
nnoremap <C-i>c :SCOSymbol expand('<cword>')<CR>
nnoremap <C-i>s :SCOSaveSearch<CR>
nnoremap <C-i>t :SCOTag ''<CR>
nnoremap <C-i>w :SCOWhoCall expand('<cword>')<CR>
nnoremap <C-i>i :SCOInclude expand('<cfile>')<CR>
nnoremap <C-i>f :SCOFile expand('<cfile>')<CR>
nnoremap <C-i>b :SCOBuffer<CR>
nnoremap <C-i>m :SCOMark<CR>
nnoremap <C-i>n :SCOMarkSmart<CR>
nnoremap <C-i>r :SCOReMark<CR>


nnoremap <C-i><C-i>g :SCOGlobal '<C-r>=expand("<cword>")<CR>'
nnoremap <C-i><C-i>c :SCOSymbol '<C-r>=expand("<cword>")<CR>'
nnoremap <C-i><C-i>s :SCOSaveSearch<CR>
nnoremap <C-i><C-i>t :SCOTag ''
nnoremap <C-i><C-i>w :SCOWhoCall '<C-r>=expand("<cword>")<CR>'
nnoremap <C-i><C-i>i :SCOInclude '<C-r>=expand("<cword>")<CR>'
nnoremap <C-i><C-i>f :SCOFile '<C-r>=expand("<cword>")<CR>'
nnoremap <C-i><C-i>x :SCOText '<C-r>=expand("<cword>")<CR>'
nnoremap <C-i><C-i>e :SCOGrep '<C-r>=expand("<cword>")<CR>'

nnoremap <C-Left> :SCOPrevious<CR>
nnoremap <C-Right> :SCONext<CR>
nnoremap <C-Up> :SCOUp<CR>
nnoremap <C-Down> :SCODown<CR>

