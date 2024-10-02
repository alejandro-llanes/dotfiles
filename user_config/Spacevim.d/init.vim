"==============================================================================
" dark_powered.vim --- dark powered configuration example for SpaceVim
" Author: Wang Shidong <wsdjeg@outlook.com>
" URL: https://spacevim.org
" License: GPLv3
"==============================================================================

" Options section
let g:spacevim_colorscheme = 'dracula'
let g:spacevim_colorscheme_bg = 'dark'
let g:spacevim_enable_guicolors = 1
let g:spacevim_statusline_separator = 'arrow'
let g:spacevim_statusline_iseparator = 'arrow'
let g:spacevim_buffer_index_type = 4
let g:spacevim_enable_tabline_filetype_icon = 1
let g:spacevim_enable_statusline_mode = 1
let g:spacevim_guifont = 'Fira Code 11'
let g:spacevim_bootstrap_before = 'myspacevim#before'
let g:spacevim_bootstrap_after = 'myspacevim#after'
let g:spacevim_filetree_direction = 'left'
let g:NERDTreeChDirMode = 2
let g:spacevim_automatic_updates = 1
let g:spacevim_enable_smooth_scrolling = "false"
"let g:spacevim_autocomplete_method = "asyncomplete"

" Custom Plugins

call add(g:spacevim_custom_plugins,
        \['ryanoasis/vim-devicons', {'merged': 0}])

call add(g:spacevim_custom_plugins,
        \['tiagofumo/vim-nerdtree-syntax-highlight', {'merged': 0}])

call add(g:spacevim_custom_plugins,
        \['kilavila/nvim-bufferlist', {'merged': 0}])

let g:_spacevim_mappings.b = {'name': '+Buffer mgmt'}
call SpaceVim#mapping#def('nnoremap', '<Leader>bl', ':BufferListOpen<CR>',
                          \ 'List open buffers',
                          \ 'BufferListOpen',
                          \ 'Buffer list opens')

"nnoremap <leader>bl :BufferList<CR>
"nnoremap <leader>bq :QuickNavOpen<CR>
"nnoremap <leader>ba :QuickNavAdd<CR>
"nnoremap <C-t> :QuickNavPrev<CR>
"nnoremap <C-n> :QuickNavNext<CR>

call add(g:spacevim_custom_plugins,
        \['ahmedkhalf/project.nvim', {'merged': 0}])

" Layers
call SpaceVim#layers#load('ctrlspace')
call SpaceVim#layers#load('colorscheme')
call SpaceVim#layers#load('git')
call SpaceVim#layers#load('telescope')

call SpaceVim#layers#load('core', {
      \ 'enable_filetree_gitstatus': 1,
      \ 'enable_filetree_filetypeicom': 1
      \})

call SpaceVim#layers#load('autocomplete',{
      \ 'auto_completion_tab_key_behavior': 'smart'
      \})

call SpaceVim#layers#load('shell', {
                            \ 'default_position':'bottom',
                            \ 'default_height': 30,
                        \})
let $SHELL = 'fish'

call SpaceVim#layers#load('lang#rust',{
      \'recommended_style': 1,
      \'format_on_save': 1,
      \'use_nvim_lsp': 1,
      \})
"call SpaceVim#layers#load('lang#python')
"let g:spacevim_lang_python_recommended_style = 1
"let g:spacevim_lang_python_format_on_save = 1

call SpaceVim#layers#load('lang#lisp')

call SpaceVim#layers#load('ui',{
      \'enable_scrollbar': 1
      \})

call SpaceVim#layers#load('lsp',{
    \})
      "\'enabled_clients': ['rust'],
      "\'override_client_cmds': {'rust':['rustup', 'run', 'stable', 'rust-analyzer']}
      "\'filetypes': ["rust"],
      "\'override_cmd': { 'rust': ['rust-analyzer'] },
    "\'override_client_cmds': {'rust':['rust-analyzer']}
