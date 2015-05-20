# Sourcegraph vim plugin

**WORK IN PROGRESS**

## Installation

To use this plugin, you must first install [srclib](https://srclib.org).

Your Vim must be complied with `+byte_offset`, to check if your version of Vim has this, run `vim --version | grep +byte_offset`

It is recommended to install this with [pathogen](https://github.com/tpope/vim-pathogen).
Once pathogen is installed run:
```
cd ~/.vim/bundle
git clone https://github.com/MarkMcCaskey/sourcegraph-vim.git
```
**NOTE**

If your default shell is Fish add `set shell=/bin/bash` or `set shell=/bin/sh` to your `.vimrc`.  Vim will throw an error when trying to run certain commands through Fish.

## Keybindings

The default keybindings are:
```
;a - Sourcegraph_jump_to_definition
;s(s,h,j,k,l) - Sourcegraph_describe
;d(d,h,j,k,l) - Sourcegraph_usages
;f - Sourcegraph_search_site
;g(g,h,j,k,l) - Sourcegraph_show_documentation
```

You can prevent these defaults from being loaded by adding `let g:sg_default_keybindings = 0` to your `.vimrc`.

You can define new keybindings by adding:
```
:noremap <silent> <keys> :call Sourcegraph_jump_to_definition()<cr>
:noremap <silent> <keys> :call Sourcegraph_describe(0)<cr>
:noremap <silent> <keys> :call Sourcegraph_usages(0)<cr>
:noremap <silent> <keys> :call Sourcegraph_search_site()<cr>
:noremap <silent> <keys> :call Sourcegraph_show_documentation(0)<cr>
```
To make direction specific buffer opening, call the above functions with one of the following values:
```
0 - use default buffer opening locations
1 - open to the left
2 - open to the right
3 - open below
4 - open above
```
to your `.vimrc`.
The control key is `<c-x>` and the alt key is `<a-x>` or `<m-x>` where x is any key.
Due to the way Vim handles keybindings by level of specificity, trying to map these over existing keybindings may cause problems.
(note: add more detail here later)

## Help

To read the documentation type `:help SG-Vim`.
The general style of the tags is to capitalize the first letter of all words and prefix all Sourcegraph-Vim specific help documentation with either `SG-Vim` or `Sourcegraph-Vim`.
For example:
```
:help SG-VimUsages
:help Sourcegraph-VimLicense
:help SG-VimContents
```

Currently the `usages` function is not fully implemented.  All other major functions work.  They may need more polishing or bug fixing, but they work at a basic level.
