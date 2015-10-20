let s:header_order = ['part', 'section', 'subsection', 'subsubsection', 'paragraph']
let s:header_labels = ['prt', 'sec', 'sub', 'ssub', 'par']

function! s:HeaderToLabel(header)
  return get(s:header_labels, index(s:header_order, a:header))
endfunction

function! s:GetNextHeaderType(header_type)
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
    if header =~ '\v^\\' . header . '\{.*\}'
      return header
    endif
  endfor
  return -1
endfunction

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

function! s:SetHeader(lnum, header_type)
  let curr = getline(a:lnum)
  let new_header = substitute(curr, '\v^\\.*(\{.*\})', '\\' . a:header_type . '\1', '')
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
    echom "Not in a section"
    return -1
  endif
  let curr_header = getline(header_line)
  let curr_header_type = s:GetHeaderType(curr_header)
  let new_header_type = s:GetNextHeaderType(curr_header)
  if new_header_type == -1
    echom "No higher header than " . curr_header_type
    return -1
  endif
  " call(function('s:SetHeader'), [header_line, new_header_type])
  call s:SetHeader(header_line, new_header_type)
  " call(function('s:SetHeader'), [header_line new_header_type])
endfunction
