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

If your default shell is Fish add `set shell=/bin/bash` or `set shell=/bin/sh` to your `.vimrc`.  Vim will throw an error when trying to run certain commands through fish.

## Keybindings

By default, the keybindings are:
```
,a - Sourcegraph_jump_to_definition()
,o - Sourcegraph_describe()
,e - Sourcegraph_usages()
,u - Sourcegraph_search_site()
```
(note, these are the keybindings used during development of sourcegraph-vim and may not be convenient on keylayouts other than Dvorak -- they will be changed once the program is closer to being fully functional)


You can prevent these defaults from being loaded by adding `let g:sg_default_keybindings = 0` to your `.vimrc`.

You can define new keybindings by adding:
```
:noremap <keys> :call Sourcegraph_jump_to_definition()<cr>
:noremap <keys> :call Sourcegraph_describe()<cr>
:noremap <keys> :call Sourcegraph_usages()<cr>
:noremap <keys> :call Sourcegraph_search_site()<cr>
```
to your `.vimrc`.
The control key is `<c-x>` and the alt key is `<a-x>` or `<m-x>` where x is any key.
Due to the way Vim handles keybindings by level of specificity, trying to map these over existing keybindings may cause problems.
(note: add more detail here later)

## Help

To read the documentation type `:help SG-Vim`.
The general style of the tags is to capitalize the first letter of all words and prefix all Sourcegraph-Vim specific help documentation with `SG-Vim` or `Sourcegraph-Vim`.
For example:
```
:help SG-VimUsages
:help Sourcegraph-VimLicense
:help SG-VimContents
```
