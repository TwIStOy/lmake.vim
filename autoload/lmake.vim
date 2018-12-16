

function! s:split_path(filename) abort
  return [fnamemodify(a:filename, ':h'), fnamemodify(a:filename, ':t')]
endfunction

function! s:merge_path(root, ...) abort
  if a:0 == 0
    return a:root
  endif

  return call('s:merge_path', [a:root . '/' . a:1] + a:000[1:])
endfunction

function! s:find_file_from_current_pos(filename) abort
  let l:current_path = s:split_path(expand('%:p'))[0]

  while l:current_path != '/'
    let l:ck_path = s:merge_path(l:current_path, a:filename)

    if filereadable(l:ck_path)
      return l:current_path
    endif

    let l:current_path = s:split_path(l:current_path)[0]
  endwhile

  return ""
endfunction

function! lmake#filter_all_rules(filename) abort
  let l:pattern = '\Vcc_library(\s\*name\s\*=\s\*\(\_["' . "'" . '\_]\)\s\*\(\_.\{-}\)\1'
  let l:rules = []
  let l:content = join(readfile(a:filename), '')

  let l:tmp = matchlist(l:content, l:pattern, 0, 1)

  while len(l:tmp) > 0
    let l:rules = add(l:rules, l:tmp[2])
    let l:tmp = matchlist(l:content, l:pattern, 0, len(l:rules) + 1)
  endwhile

  return l:rules
endfunction

function! lmake#get_build_root() abort
  let l:res = s:find_file_from_current_pos('BLADE_ROOT')
  if l:res == ''
    return expand('%:p:h')
  endif

  return l:res
endfunction

function! lmake#get_current_rule_file() abort
  return s:find_file_from_current_pos('BUILD') . '/BUILD'
endfunction

function! lmake#read_rule_file() abort
  let l:filename = s:find_file_from_current_pos('BUILD') . '/BUILD'

  if l:filename != ""
    return join(readfile(l:filename), "")
  endif

  return ""
endfunction

function! lmake#build_file_on_current_pos() abort
  let l:res = matchlist(getline('.'), '\V\(\_["' . "'" . '\_]\)\(\_.\{-}\)\1')

  if len(l:res) == 0
    return ""
  endif

  let l:path = l:res[2]

  if match(l:path, '^//') == 0
    let l:path = s:merge_path(lmake#get_build_root(), l:path[2:])
    return l:path[:match(l:path, '\V:\_.\*')-1]
  endif

  return expand('%:p')
endfunction

function! lmake#get_available_rules() abort
  let l:filename = lmake#build_file_on_current_pos()

  if l:filename == ""
    return []
  endif

  return lmake#filter_all_rules(l:filename)
endfunction

function! lmake#complete_items() abort
  let l:res = []
  let l:root = lmake#get_build_root()
  let l:filename = lmake#build_file_on_current_pos()
  for l:item in lmake#get_available_rules()
    let l:tmp = {
          \ 'word': l:item,
          \ 'menu': 'RULE at ' . l:filename[len(l:root)+1:]
          \ }
    let l:res = add(l:res, l:tmp)
  endfor

  return l:res
endfunction

