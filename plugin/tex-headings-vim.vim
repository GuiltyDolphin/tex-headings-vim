" File: tex-headings.vim
" Author: GuiltyDolphin (Ben Moon)
" Description: Plugin for changing (La)TeX section headers.
" License: GNU GPL version 3

if exists("g:loaded_tex_headings")
  finish
endif
let g:loaded_tex_headings = 1

let s:header_order = ['part', 'section', 'subsection', 'subsubsection', 'paragraph', 'subparagraph']
let s:header_labels = ['prt', 'sec', 'sub', 'ssub', 'par', 'par']

" 1 -> Replace references regardless
" 2 -> Replace references with choice
if !exists("g:tex_headings_update_refs")
  let g:tex_headings_update_refs = 0
endif

" Get the common label used for a particular header.
function! s:HeaderToLabel(header)
  return get(s:header_labels, index(s:header_order, a:header))
endfunction

" Returns nonzero if there are no higher headers than that given.
function! s:IsHighestHeader(header)
  return index(s:header_order, a:header) == 0
endfunction

" Returns nonzero if there are no lower headers than that given.
function! s:IsLowestHeader(header)
  return index(s:header_order, a:header) == len(s:header_order) - 1
endfunction

" Return the nex highest header, if any.
function! s:GetHigherHeaderType(header_type)
  if s:IsHighestHeader(a:header_type)
    return ''
  else
    let idx = index(s:header_order, a:header_type)
    return get(s:header_order, idx - 1)
  endif
endfunction

" Return the next lowest header, if any.
function! s:GetLowerHeaderType(header_type)
  if s:IsLowestHeader(a:header_type)
    return ''
  else
    let idx = index(s:header_order, a:header_type)
    return get(s:header_order, idx + 1)
  endif
endfunction

" Generate a regular expression for matching a particular header.
function! s:GetHeaderRegex(header_type)
  return '\v^\\' . a:header_type . '\{.*\}'
endfunction

" Return 1 if the line starts with a valid TeX section header,
" 0 otherwise.
function! s:MatchesSection(lnum)
  let curr_line = getline(a:lnum)
  for header in s:header_order
    if curr_line =~ s:GetHeaderRegex(header)
      return 1
    endif
  endfor
endfunction

" Determine the header type of a particular line.
function! s:GetHeaderType(line_conts)
  for header in s:header_order
    if a:line_conts =~ s:GetHeaderRegex(header)
      return header
    endif
  endfor
endfunction

" Get the line number of the current section header.
function! s:GetCurrentSectionHeaderLine(lnum)
  let lineno = a:lnum
  while lineno > 0
    if s:MatchesSection(lineno)
      return lineno
    endif
    let lineno = lineno - 1
  endwhile
  return -1
endfunction

" Update any references to a label that has changed.
function! s:UpdateReferences(old_label, new_label, name)
  let search_term = '\<' . a:old_label . ':' . a:name . '\>'
  let replace_term = a:new_label . ':' . a:name
  if g:tex_headings_update_refs != 0
    if g:tex_headings_update_refs == 1
      let modifiers = 'ge'
    elseif g:tex_headings_update_refs == 2
      let modifiers = 'gce'
    endif
    let save_cursor = getcurpos()
    exec '%substitute/' . search_term . '/' . replace_term . '/' . modifiers
    call setpos('.', save_cursor)
  endif
endfunction

" Change the header at line a:lnum to a:header_type, if there
" is a header at that position.
function! s:SetHeader(lnum, header_type)
  let curr = getline(a:lnum)
  let new_header = substitute(curr, '\v^\\\w+(\{.*\})', '\\' . a:header_type . '\1', '')
  call setline(a:lnum, new_header)
endfunction

" Change the header label at a particular line.
function! s:UpdateLabel(lnum, old_label_type, new_label_type)
  let curr = getline(a:lnum)
  let name = matchstr(
        \ curr,
        \ '\v\\label\{' . a:old_label_type . ':\zs.*\ze\}')
  let new_label = substitute(
        \ curr,
        \ '\v^\\label\{' . a:old_label_type . ':(.*)\}',
        \ '\\label\{' . a:new_label_type . ':\1\}', '')
  call setline(a:lnum, new_label)
  call s:UpdateReferences(a:old_label_type, a:new_label_type, name)
endfunction

" Change a TeX header on a given line.
function! s:TexChangeHeader(lnum, type)
  let header_line = s:GetCurrentSectionHeaderLine(a:lnum)
  if header_line == -1
    echom "No header found"
    return
  endif
  let curr_header = getline(header_line)
  let curr_header_type = s:GetHeaderType(curr_header)

  if a:type =~ 'higher'
    let new_header_type = s:GetHigherHeaderType(curr_header_type)
  elseif a:type =~ 'lower'
    let new_header_type = s:GetLowerHeaderType(curr_header_type)
  endif

  if empty(new_header_type)
    echom "No " . a:type . " header than " . curr_header_type
    return
  endif
  let old_label = s:HeaderToLabel(curr_header_type)
  let new_label = s:HeaderToLabel(new_header_type)
  call s:SetHeader(header_line, new_header_type)
  call s:UpdateLabel(header_line + 1, old_label, new_label)
endfunction

" Set the current TeX header to the next highest header.
function! TeXHeaderHigher(...)
  if a:0 == 0
    let lnum = line('.')
  else
    let lnum = a:1
  endif
  call s:TexChangeHeader(lnum, 'higher')
endfunction

" Set the current TeX header to the next lowest header.
function! TeXHeaderLower(...)
  if a:0 == 0
    let lnum = line('.')
  else
    let lnum = a:1
  endif
  call s:TexChangeHeader(lnum, 'lower')
endfunction
