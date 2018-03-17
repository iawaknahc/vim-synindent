if exists("g:synindent_loaded") || &cp
  finish
endif
let g:synindent_loaded=1

function! s:get_stats(lines) abort
  let i = 0
  let l = len(a:lines)
  " Number of line indented with spaces
  let spaces = 0
  " Number of line indented with tabs
  let tabs = 0
  " Number of spaces for 1 indentation level
  let indent = 0

  while i < l
    let line = a:lines[i]
    let i += 1

    " Ignore empty lines
    if !len(line) || line =~# '^\s*$'
      continue
    endif

    " Ignore lines that are comments or constants
    let syn_group = synIDattr(synIDtrans(synID(i, 1, 1)), "name")
    if syn_group == "Comment" || syn_group == "Constant"
      continue
    endif

    " Count tab
    if line =~# '^\t'
      let tabs += 1
    endif
    " Count space
    if line =~# '^ '
      let spaces += 1
      " Guess indent
      let n = len(matchstr(line, '^ *'))
      if n > 1 && (indent == 0 || n < indent)
        let indent = n
      endif
    endif
  endwhile

  return {'spaces': spaces, 'tabs': tabs, 'indent': indent}
endfunction

function! s:apply_stats_to_options(stats) abort
  let spaces = a:stats.spaces
  let tabs = a:stats.tabs
  let indent = a:stats.indent

  if spaces == 0 && tabs == 0
    return
  endif

  if tabs > spaces
    let i = get(g:, 'synindent_indent', 4)
    execute "setlocal tabstop=" . i . " shiftwidth=" . i . " noexpandtab"
  elseif indent > 0
    let i = indent
    execute "setlocal softtabstop=" . i . " shiftwidth=" . i . " expandtab"
  endif
endfunction

function! s:detect() abort
  if &readonly
    return
  endif
  let stats = s:get_stats(getline(1, 1024))
  return s:apply_stats_to_options(stats)
endfunction

augroup SynIndent
  autocmd!
  autocmd FileType * call s:detect()
augroup END
