if exists('b:did_ftplugin') | finish | endif

" {{{ CONFIGURATION
if !exists('g:markdown_disable_table_mode') ||  g:markdown_disable_table_mode == 0
    au InsertLeave silent! TableModeDisable
    imap <buffer> | <c-o>:silent! TableModeEnable<cr>
endif

if !exists('g:markdown_flavor')
    let g:markdown_flavor = 'github'
endif

" }}}


" {{{ OPTIONS

setlocal textwidth=0
setlocal ts=4 sw=4 expandtab smarttab
setlocal comments=n:>,b:-\ [\ ],b:-\ [x],b:*,b:-,b:1.,b:2.,b:3.,b:4.,b:5.,b:6.,b:7.,b:8.,b:9.,b:+,se:```
setlocal commentstring=>\ %s
setlocal formatoptions=tron
" setlocal formatoptions=ctnqro

setlocal formatlistpat=^\\s*             "numbered lists
setlocal formatlistpat+=\\d\\+\\.\\s\\+
setlocal formatlistpat+=\\\|             "OR
setlocal formatlistpat+=^\\s*            "bulleted lists lists
setlocal formatlistpat+=[+-\\*] 
setlocal formatlistpat+=\\s\\+

setlocal nolisp
setlocal autoindent
setlocal nocindent
setlocal nosmartindent

" Enable spelling and completion based on dictionary words
if !exists('g:markdown_disable_spelling_features') || g:markdown_disable_spelling_features == 0
    setlocal spell
    " Custom dictionary for emoji
    execute 'setlocal dictionary+=' . shellescape(expand('<sfile>:p:h:h')) . '/dict/emoticons.dict'
    setlocal iskeyword+=:,+,-
    setlocal complete+=k
endif

" Folding
if !exists('g:markdown_disable_folding') || g:markdown_disable_folding == 0
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

function! s:IsAnEmptyListItem()
    return getline('.') =~ '\v^\s*%([-*+]|\d\.)\s*$'
endfunction

function! s:IsANonEmptyNumberList()
    return getline('.') =~ '^\s*\d\.\s'
endfunction

function! s:IsAnEmptyCheckListItem()
    return getline('.') =~ '\v^\s*%([-*+]|\d\.)\s\[\s\]\s*$'
endfunction

function! s:IsAnEmptyQuote()
    return getline('.') =~ '\v^\s*(\s?\>)+\s*$'
endfunction

function! s:MarkdownCarriageReturn()
    if s:IsANonEmptyNumberList()
        echom "nonemptynumlist"
        return "\<esc>:normal yyp0\<c-a>lllD\<cr>A"
    elseif s:IsAnEmptyListItem() || s:IsAnEmptyQuote() || s:IsAnEmptyCheckListItem()
        return "\<C-O>:normal 0Do\<CR>"
    else
        return "\<CR>"
    endif
endfunction

" }}}


" {{{ MAPPINGS

" Commands
command! -nargs=0 -range MarkdownEditBlock :<line1>,<line2>call markdown#EditBlock()

if !exists('g:markdown_disable_motions') || g:markdown_disable_motions == 0
    " Jumping around
    noremap   <silent>  <buffer>  <script>  ]]  :<C-u>call  <SID>JumpToHeader(1,  0)<CR>
    noremap   <silent>  <buffer>  <script>  [[  :<C-u>call  <SID>JumpToHeader(0,  0)<CR>
    vnoremap  <silent>  <buffer>  <script>  ]]  :<C-u>call  <SID>JumpToHeader(1,  1)<CR>
    vnoremap  <silent>  <buffer>  <script>  [[  :<C-u>call  <SID>JumpToHeader(0,  1)<CR>
    noremap   <silent>  <buffer>  <script>  ][  <nop>
    noremap   <silent>  <buffer>  <script>  []  <nop>

endif

" }}}



function! s:isAtStartOfLine(mapping)
    let text_before_cursor = getline('.')[0 : col('.')-1]
    let mapping_pattern = '\V' . escape(a:mapping, '\')
    let comment_pattern = '\V' . escape(substitute(&l:commentstring, '%s.*$', '', ''), '\')
    return (text_before_cursor =~? '^' . ('\v(' . comment_pattern . '\v)?') . '\s*\v' . mapping_pattern . '\v$')
endfunction

if !exists("g:markdown_disable_clear_empty_on_cr") || g:markdown_disable_clear_empty_on_cr == 0
    " Remove only empty list items when press <CR>
    imap <silent> <buffer> <script> <expr> <CR> <SID>MarkdownCarriageReturn()
endif

let b:did_ftplugin = 1
