"
"
"
"
"
if exists( "g:sg_vim_loaded" )
	finish
endif
let g:sg_vim_loaded=002

"consider reading from configuration file
let s:supported_languages=["go","python","java","nodejs","ruby"]

if !executable( "src" ) 
	echom "src(https://srclib.org/) is required to use this plugin"
	finish
endif



"This function can be used to get a list of currently supported languages
"so that this plugin only runs when editing supported files
"
"this function currently doesn't work
function SetLangVars()
	let s:src_temp = system( "src toolchain list" )
	let s:src_tool_list = split( s:src_temp )
	unlet s:src_temp
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

function SG_Keybindings()
	if ! exists( "g:sg_default_keybindings" )
		let g:sg_default_keybindings = 1
	endif
	if g:sg_default_keybindings 
		:noremap ,a :call Sourcegraph_jump_to_definition()<cr>
		:noremap ,o :call Sourcegraph_describe()<cr>
		:noremap ,e :call Sourcegraph_usages()<cr>
		:noremap ,u :call Sourcegraph_search_site()<cr>
	else
		:unmap ,a
		:unmap ,o
		:unmap ,e
		:unmap ,u
	endif	
endfunction

function Sourcegraph_jump_to_definition()
	:execute "normal! :!src api describe --file " . bufname("%") . " --start-byte " . Get_byte_offset() . "\<cr>"	
	:echom "sourcegraph_jump_to_definition"
endfunction

function Sourcegraph_describe()
	:echom "sourcegraph_describe"
endfunction

function Sourcegraph_usages()
	:echom "sourcegraph_usages"
endfunction


function Sourcegraph_search_site()
	let l:base_url="https://sourcegraph.com/"
	if( mode() ==? "v" ) 
		"consider updating to command that maintains selected text
		execute "normal! \"ay"
	else "not in visual mode
		"set search_string to word under the cursor
		execute "normal! mqviw\"ay`q"
	endif
	let l:search_string = @a


	"try opening with browser
	"TODO: find better way to open in the background
	let l:url = '"' . l:base_url . "search?q=" . l:search_string . '"'
	if executable( 0 ) "mac OS X and Linux
		"open is a keyword in VimL
		"TODO: find way to call open
		":call system( "open " . l:url . " &" )
		"calling execute below with silent causes problems
	elseif executable( "sensible-browser" ) "debian-based linux
		:silent execute "!sensible-browser"  l:url . " &"
	elseif executable( "xdg-open" ) "linux
		:silent execute "!xdg-open" l:url . " &"
	elseif executable( "firefox" )
		:silent execute "!firefox" l:url
	elseif executable( "chromium-browser" ) . " &"
		:silent execute "!chromium-browser" l:url
	else 
		echom "No browser found, please submit a bug report at https://github.com/MarkMcCaskey/sourcegraph-vim"
	endif
	:redraw!

	unlet l:search_string
	unlet l:base_url
	unlet l:url
endfunction
	
function Supported_file()
	if index( s:supported_languages, &filetype ) != -1
		return 1
	endif
	return 0
endfunction

function Get_byte_offset()
	"added viw so that if called on first letter it stays on the same word
	execute "normal! mqviwb"
	let l:retval = line2byte(line("."))+col(".")
	execute "normal! `q"
	return l:retval
endfunction

:call SG_Keybindings()
