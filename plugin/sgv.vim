"
"
"
"
"

if exists( "g:sg_vim_loaded" )
	finish
endif
let g:sg_vim_loaded=001

"consider reading from configuration file
let s:supported_languages=["go","python","java","nodejs","ruby"]

if !executable( "src" )
	echom "src(https://srclib.org/) is required to use this plugin"
	finish
endif


function SetLangVars()
	let s:src_tool_list = split(execute "normal! :!src toolchain list")
	let l:i = 0
	let l:base_url = "sourcegraph.com/sourcegraph/srclib-"

	while l:i < len(s:src_tool_list)
		let l:j = 0
		while j < len(s:supported_languages)
			if s:src_tool_list[l:i] == l:base_url . s:supported_languges[l:j]
				if(!exists "s:" . s:supported_languages[l:j])
					execute "normal! let " . s:supported_languages[l:j] . " = 1"
				endif
			endif
			let l:j += 1
		endwhile
		let l:i += 1
		unlet l:j
	endwhile

	unlet l:i
	unlet s:src_tool_list
	unlet l:base_url
endfunction

function! SG_Keybindings()
	if ! exists( "g:sg_default_keybindings" )
		let g:sg_default_keybindings = 1
	endif
	if g:sg_default_keybindings 
		echom "in here"
		execute "normal! :noremap <C-a> :echom \"test\"<CR>"
		"execute "normal! :noremap <C-1> :call Sourcegraph_jump_to_definition()<CR>"
		execute "normal! :noremap <C-2> :call Sourcegraph_describe()<CR>"
		execute "normal! :noremap <C-3> :call Sourcegraph_usages()<CR>"
	else
		execute "normal! :unmap <C-1>" 
		execute "normal! :unmap <C-2>"
		execute "normal! :unmap <C-3>"
	endif	
endfunction

function Sourcegraph_jump_to_definition()
	echom "sourcegraph_jump_to_definition"
endfunction

function Sourcegraph_describe()
	echom "sourcegraph_describe"
endfunction

function Sourcegraph_usages()
	echom "sourcegraph_usages"
endfunction


function Sourcegraph_search_site(search_terms)
	let l:base_url="https://sourcegraph.com/"
	if( mode() ==? "v" ) 
		"consider updating to command that maintains selected text
		execute "normal! \"ay"
	else "not in visual mode
		"set search_string to word under the cursor
		execute "normal! mqviw\"ay`q"
	endif
	let l:search_string = @a

	execute "normal! :!xdg-open \"" . l:base_url . "search?q=" . l:search_string . "\" ; sleep 5"
	unlet l:search_string
	unlet l:base_url
endfunction
	




