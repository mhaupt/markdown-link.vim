" Vim plugin for creating Markdown links from clipboard URLs
" Only applies to Markdown files
" Maps Cmd-V to replace selected text with [text](url) format

if exists('g:loaded_markdown_link_plugin')
  finish
endif
let g:loaded_markdown_link_plugin = 1

function! s:IsURL(text)
  let l:clean_text = substitute(a:text, '\s\+$', '', '')
  return l:clean_text =~# '^https\?://\S\+$'
endfunction

function! s:CreateMarkdownLink()
  let l:clipboard = substitute(@+, '\s\+$', '', '')
  
  if !s:IsURL(l:clipboard)
    let l:old_unnamed = @"
    let @" = @+
    normal! gvp
    let @" = l:old_unnamed
    return
  endif
  
  let l:old_reg = @z
  normal! gv"zy
  let l:selected_text = @z
  let @z = l:old_reg
  
  let l:link = '[' . l:selected_text . '](' . l:clipboard . ')'
  
  " Replace selection by putting the link into a register and pasting
  let l:old_unnamed = @"
  let @" = l:link
  normal! gvp
  let @" = l:old_unnamed
endfunction

augroup MarkdownLinkPlugin
  autocmd!
  autocmd FileType markdown silent! vunmap <buffer> <D-v>
  autocmd FileType markdown vnoremap <buffer> <D-v> :<C-u>call <SID>CreateMarkdownLink()<CR>
augroup END

if has('gui_macvim')
  autocmd FileType markdown silent! vunmenu Edit.Paste
endif
