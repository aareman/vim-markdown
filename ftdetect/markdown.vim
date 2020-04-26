if exists("g:markdown_disable_pandoc_integration") && g:markdown_disable_pandoc_integration == 1
    au! BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} set filetype=markdown
else
    au! BufRead,BufNewFile *.{md,mdown,mkd,mkdn,markdown,mdwn} set filetype=pandoc.markdown
endif
