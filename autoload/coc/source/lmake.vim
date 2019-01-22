function! coc#source#lmake#init() abort
  return {
        \ 'shortcut': 'lmake',
        \ 'priority': 99,
        \ 'filetypes': ['bzl'],
        \ 'firstMatch': 1
        \ }
endfunction


function! coc#source#lmake#complete(opt, cb) abort
  call a:cb(lmake#complete_items())
endfunction
