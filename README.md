TeX-headings-vim
================

Vim plugin for modifying (La)TeX section headers.

Available on [GitHub](https://www.github.com/GuiltyDolphin/tex-headings-vim)


Installing
----------

If you have [Vundle](https://www.github.com/VundleVim/Vundle.vim),
then just add `Plugin 'guiltydolphin/tex-headings-vim'` to the
plugin section of your vimrc.

Setup
-----

To use the plugin, simply map some keys to
`:call TeXHeaderHigher()` and `:call TeXHeaderLower()`.

For example:

```
augroup TeXHeaderBinds
  au FileType tex nnoremap <buffer> <localleader>hh :call TeXHeaderHigher()<CR>
  au FileType tex nnoremap <buffer> <localleader>hl :call TeXHeaderLower()<CR>
augroup END
```

The `g:tex_headings_update_refs` variable controls how references
are handled.

0. Do nothing with references of the section.
1. Update references without asking.
2. Update references, but ask before each one.

Note that if a section has the label `\label{sec:foo}`, then
anything that matches `\<sec:foo\>` is considered a reference.

Example
-------

Using the bindings defined above, and
`g:tex_headings_update_refs` set to 1:

With the text:

```
... some text ...

\section{foo}
\label{sec:foo}

... some text ...
<CURSOR>

... Section~\ref{sec:foo}
```

Using `<localleader>hl` would result in

```
... some text ...

\subsection{foo}
\label{sub:foo}

... some text ...
<CURSOR>

... Section~\ref{sub:foo}
```

License
-------

Copyright (c) 2015 GuiltyDolphin (Ben Moon)

Licensed under GNU GPLv3 - see the `LICENSE` file for more
information.
