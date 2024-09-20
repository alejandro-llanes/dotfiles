function! myspacevim#before() abort
  let $VIMON = "on"
endfunction

function myspacevim#after() abort
"" autocmd User NerdTreeInit
""         g:NERDTreeDirArrowExpandable = '?'
""         g:NERDTreeDirArrowCollapsible = '?'
        let g:NERDTreeFileLines = 1
        let g:NERDTreeChDirMode = 2
endfunction
