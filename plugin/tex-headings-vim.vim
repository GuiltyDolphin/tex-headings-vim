let s:header_order = ['part', 'section', 'subsection', 'subsubsection', 'paragraph']
let s:header_labels = ['prt', 'sec', 'sub', 'ssub', 'par']

function! s:HeaderToLabel(header)
  return get(s:header_labels, index(s:header_order, a:header))
endfunction

function! s:GetHigherHeaderType(header_type)
  let idx = index(s:header_order, a:header_type)
  if idx == 0
    return -1
  endif
  return get(s:header_order, idx - 1)
endfunction

function! s:MatchesSection(lnum)
  let curr_line = getline(a:lnum)
  for header in s:header_order
    if curr_line =~ '\v^\\' . header . '\{.*\}'
      return 1
    endif
  endfor
  return 0
endfunction

function! s:GetHeaderType(line_conts)
  for header in s:header_order
    if a:line_conts =~ '\v^\\' . header . '\{.*\}'
      return header
    endif
  endfor
  return -1
endfunction

" Get the line number of the current section header.
function! s:GetCurrentSectionHeaderLine(lnum)
  let lineno = a:lnum
  while lineno > 1
    if s:MatchesSection(lineno)
      return lineno
    endif
    let lineno = lineno - 1
  endwhile
  return -1
endfunction

" Change the header at line a:lnum to a:header_type, if there
" is a header at that position.
function! s:SetHeader(lnum, header_type)
  let curr = getline(a:lnum)
  let new_header = substitute(curr, '\v^\\\w+(\{.*\})', '\\' . a:header_type . '\1', '')
  call setline(a:lnum, new_header)
  call s:SetLabel(a:lnum + 1, s:HeaderToLabel(a:header_type))
endfunction

function! s:SetLabel(lnum, label_type)
  let curr = getline(a:lnum)
  let new_label = substitute(curr, '\v^\\label\{.*:(.*)\}', '\\label\{' . a:label_type . ':\1\}', '')
  call setline(a:lnum, new_label)
endfunction

function! HeaderUp(lnum)
  let header_line = s:GetCurrentSectionHeaderLine(a:lnum)
  if header_line == -1
    echom "No header found"
    return -1
  endif
  let curr_header = getline(header_line)
  let curr_header_type = s:GetHeaderType(curr_header)
  let new_header_type = s:GetHigherHeaderType(curr_header_type)
  if new_header_type == -1
    echom "No higher header than " . curr_header_type
    return -1
  endif
  call s:SetHeader(header_line, new_header_type)
endfunction
