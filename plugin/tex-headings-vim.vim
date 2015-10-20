let s:header_order = ['part', 'section', 'subsection', 'subsubsection', 'paragraph']
let s:header_labels = ['prt', 'sec', 'sub', 'ssub', 'par']

function! s:HeaderToLabel(header)
  return get(s:header_labels, index(s:header_order, a:header))
endfunction


function! s:IsHighestHeader(header)
  return index(s:header_order, a:header) == 0
endfunction

function! s:IsLowestHeader(header)
  return index(s:header_order, a:header) == len(s:header_order) - 1
endfunction

function! s:GetHigherHeaderType(header_type)
  if s:IsHighestHeader(a:header_type)
    return -1
  else
    let idx = index(s:header_order, a:header_type)
    return get(s:header_order, idx - 1)
  endif
endfunction

function! s:GetLowerHeaderType(header_type)
  if s:IsLowestHeader(a:header_type)
    return -1
  else
    let idx = index(s:header_order, a:header_type)
    return get(s:header_order, idx + 1)
  endif
endfunction

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
  return 0
endfunction

function! s:GetHeaderType(line_conts)
  for header in s:header_order
    if a:line_conts =~ s:GetHeaderRegex(header)
      return header
    endif
  endfor
  return -1
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

function! s:TexChangeHeader(lnum, type)
  let header_line = s:GetCurrentSectionHeaderLine(a:lnum)
  if header_line == -1
    echom "No header found"
    return -1
  endif
  let curr_header = getline(header_line)
  let curr_header_type = s:GetHeaderType(curr_header)

  if a:type =~ 'higher'
    let new_header_type = s:GetHigherHeaderType(curr_header_type)
  elseif a:type =~ 'lower'
    let new_header_type = s:GetLowerHeaderType(curr_header_type)
  endif

  if new_header_type == -1
    echom "No " . a:type . " header than " . curr_header_type
    return -1
  endif
  call s:SetHeader(header_line, new_header_type)
endfunction

function! TeXHeaderHigher(...)
  if a:0 == 0
    let lnum = line('.')
  else
    let lnum = a:1
  endif
  call s:TexChangeHeader(lnum, 'higher')
endfunction

function! TeXHeaderLower(...)
  if a:0 == 0
    let lnum = line('.')
  else
    let lnum = a:1
  endif
  call s:TexChangeHeader(lnum, 'lower')
endfunction
