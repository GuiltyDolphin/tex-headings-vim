TeX-headings-vim
================

Vim plugin for modifying (La)TeX section headers.


Installing
----------

If you have [Vundle](https://www.github.com/VundleVim/Vundle.vim),
then just add `Plugin 'guiltydolphin/tex-headings-vim'` to the
plugin section of your vimrc.

To use the plugin, simply map some keys to
`:call TeXHeaderHigher()` and `:call TeXHeaderLower()`.

For example:

```
augroup TeXHeaderBinds
  au FileType tex nnoremap <buffer> <localleader>hh :call TeXHeaderHigher()<CR>
  au FileType tex nnoremap <buffer> <localleader>hl :call TeXHeaderLower()<CR>
augroup END
```

License
-------

Copyright (c) 2015 GuiltyDolphin (Ben Moon)

Licensed under GNU GPLv3 - see the `LICENSE` file for more
information.
