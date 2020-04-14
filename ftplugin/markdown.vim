if exists('b:did_ftplugin') | finish | endif

" {{{ CONFIGURATION
silent! TableModeEnable

if !exists('g:markdown_flavor')
  let g:markdown_flavor = 'github'
endif

if !exists('g:markdown_enable_folding')
  let g:markdown_enable_folding = 0
endif

if !exists('g:markdown_enable_mappings')
  " make it compatible with previous configuration value
  if exists('g:markdown_include_default_mappings')
    let g:markdown_enable_mappings = g:markdown_include_default_mappings
  else
    let g:markdown_enable_mappings = 1
  endif
endif

if !exists('g:markdown_enable_insert_mode_mappings')
  " make it compatible with previous configuration value
  if exists('g:markdown_include_insert_mode_default_mappings')
    let g:markdown_enable_insert_mode_mappings = g:markdown_include_insert_mode_default_mappings
  else
    let g:markdown_enable_insert_mode_mappings = 1
  endif
endif

if !exists('g:markdown_enable_insert_mode_leader_mappings')
    let g:markdown_enable_insert_mode_leader_mappings = 0
endif

if !exists('g:markdown_drop_empty_blockquotes')
    let g:markdown_drop_empty_blockquotes = 0
endif

if !exists('g:markdown_mapping_switch_status')
  let g:markdown_mapping_switch_status = '<space>'
endif

if !exists('g:markdown_enable_spell_checking')
  let g:markdown_enable_spell_checking = 1
endif

if !exists('g:markdown_enable_input_abbreviations')
  let g:markdown_enable_input_abbreviations = 1
endif

" }}}


" {{{ OPTIONS

setlocal textwidth=0
setlocal ts=4 sw=4 expandtab smarttab
setlocal comments=n:>,b:-\ [\ ],b:-\ [x],b:*,b:-,b:+,se:```
setlocal commentstring=>\ %s
" setlocal formatoptions=tron
setlocal formatoptions=ctnqro

setlocal formatlistpat=^\\s*             "numbered lists
setlocal formatlistpat+=\\d\\+\\.\\s\\+
setlocal formatlistpat+=\\\|             "OR
setlocal formatlistpat+=^\\s*            "bulleted lists lists
setlocal formatlistpat+=[+-\\*] 
setlocal formatlistpat+=\\s\\+

setlocal nolisp
setlocal autoindent
setlocal nosmartindent

" Enable spelling and completion based on dictionary words
if &spelllang !~# '^\s*$' && g:markdown_enable_spell_checking
  setlocal spell
endif

" Custom dictionary for emoji
execute 'setlocal dictionary+=' . shellescape(expand('<sfile>:p:h:h')) . '/dict/emoticons.dict'
setlocal iskeyword+=:,+,-
setlocal complete+=k

if g:markdown_enable_input_abbreviations
  " Replace common ascii emoticons with supported emoji
  iabbrev <buffer> :-) :smile:
  iabbrev <buffer> :-D :laughing:
  iabbrev <buffer> :-( :disappointed:

  " Replace common punctuation
  iabbrev <buffer> ... …
  iabbrev <buffer> << «
  iabbrev <buffer> >> »
endif

" Folding
if g:markdown_enable_folding
  setlocal foldmethod=expr
  setlocal foldexpr=markdown#FoldLevelOfLine(v:lnum)
endif

" }}}


" {{{ FUNCTIONS

function! s:JumpToHeader(forward, visual)
  let cnt = v:count1
  let save = @/
  let pattern = '\v^#{1,6}.*$|^.+\n%(\-+|\=+)$'
  if a:visual
    normal! gv
  endif
  if a:forward
    let motion = '/' . pattern
  else
    let motion = '?' . pattern
  endif
  while cnt > 0
	  silent! execute motion
	  let cnt = cnt - 1
  endwhile
  call histdel('/', -1)
  let @/ = save
endfunction

function! s:Indent(indent)
  if getline('.') =~ '\v^\s*%([-*+]|\d\.)\s*$'
    if a:indent
      normal >>
    else
      normal <<
    endif
    call setline('.', substitute(getline('.'), '\([-*+]\|\d\.\)\s*$', '\1 ', ''))
    normal $
  elseif getline('.') =~ '\v^\s*(\s?\>)+\s*$'
    if a:indent
      call setline('.', substitute(getline('.'), '>\s*$', '>> ', ''))
    else
      call setline('.', substitute(getline('.'), '\s*>\s*$', ' ', ''))
      call setline('.', substitute(getline('.'), '^\s\+$', '', ''))
    endif
    normal $
  endif
endfunction

function! s:IsAnEmptyListItem()
  return getline('.') =~ '\v^\s*%([-*+]|\d\.)\s*$'
endfunction

function! s:IsACheckListItem()
  return getline('.') =~ '\v^\s*%([-*+]|\d\.)\s[ ].*$'
endfunction

function! s:IsAnEmptyQuote()
  return getline('.') =~ '\v^\s*(\s?\>)+\s*$'
endfunction

" }}}


" {{{ MAPPINGS

" Commands
command! -nargs=0 -range MarkdownEditBlock :<line1>,<line2>call markdown#EditBlock()

if g:markdown_enable_mappings
  " Jumping around
    noremap   <silent>  <buffer>  <script>  ]]  :<C-u>call  <SID>JumpToHeader(1,  0)<CR>
    noremap   <silent>  <buffer>  <script>  [[  :<C-u>call  <SID>JumpToHeader(0,  0)<CR>
    vnoremap  <silent>  <buffer>  <script>  ]]  :<C-u>call  <SID>JumpToHeader(1,  1)<CR>
    vnoremap  <silent>  <buffer>  <script>  [[  :<C-u>call  <SID>JumpToHeader(0,  1)<CR>
    noremap   <silent>  <buffer>  <script>  ][  <nop>
    noremap   <silent>  <buffer>  <script>  []  <nop>

  if g:markdown_enable_insert_mode_mappings
    " Indenting things
    inoremap <silent> <buffer> <script> <expr> <Tab>
      \ <SID>IsAnEmptyListItem() \|\| <SID>IsAnEmptyQuote() ? '<C-O>:call <SID>Indent(1)<CR>' : '<Tab>'
    inoremap <silent> <buffer> <script> <expr> <S-Tab>
      \ <SID>IsAnEmptyListItem() \|\| <SID>IsAnEmptyQuote() ? '<C-O>:call <SID>Indent(0)<CR>' : '<Tab>'

    " if g:markdown_drop_empty_blockquotes
    "   " Remove empty quote and list items when press <CR>
    "   inoremap <silent> <buffer> <script> <expr> <CR> <SID>IsAnEmptyQuote() \|\| <SID>IsAnEmptyListItem() ? '<C-O>:normal 0D<CR>' : '<CR>'
    " else
    "   " Remove only empty list items when press <CR>
    "   inoremap <silent> <buffer> <script> <expr> <CR> <SID>IsAnEmptyListItem() ? '<C-O>:normal 0D<CR>' : '<CR>'
    " endif

  endif

endif

" }}}



function! s:isAtStartOfLine(mapping)
  let text_before_cursor = getline('.')[0 : col('.')-1]
  let mapping_pattern = '\V' . escape(a:mapping, '\')
  let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
  return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction

  " Remove only empty list items when press <CR>
  inoremap <silent> <buffer> <script> <expr> <CR> <SID>IsAnEmptyListItem() ? '<C-O>:normal 0Do<CR>' :  '<CR>'

    noremap   <silent>  <buffer>  <script>  ]]  :<C-u>call  <SID>JumpToHeader(1,  0)<CR>
    noremap   <silent>  <buffer>  <script>  [[  :<C-u>call  <SID>JumpToHeader(0,  0)<CR>
    vnoremap  <silent>  <buffer>  <script>  ]]  :<C-u>call  <SID>JumpToHeader(1,  1)<CR>
    vnoremap  <silent>  <buffer>  <script>  [[  :<C-u>call  <SID>JumpToHeader(0,  1)<CR>
    noremap   <silent>  <buffer>  <script>  ][  <nop>
    noremap   <silent>  <buffer>  <script>  []  <nop>

let b:did_ftplugin = 1
