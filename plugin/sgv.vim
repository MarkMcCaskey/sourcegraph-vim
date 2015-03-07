" Vim plugin for srclib (https://srclib.org)
" Last Change: Mar 1 2015
" Maintainer: mmccask2@gmu.edu
" License: 

if exists( "g:sg_vim_loaded" )
	finish
endif
let g:sg_vim_loaded=004

"consider reading from configuration file
let s:supported_languages=["go","python","java","nodejs","ruby"]

if !executable( "src" ) 
	echom "src(https://srclib.org/) is required to use this plugin"
	finish
endif

"close plugin if editing a file not currently supported
"DISABLED FOR TESTING PURPOSES
""if ! Supported_file()
""       finish
""endif       

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
		noremap ,aa :call Sourcegraph_jump_to_definition(0)<cr>
		noremap ,oo :call Sourcegraph_describe(0)<cr>
		noremap ,ee :call Sourcegraph_usages(0)<cr>
		noremap ,uu :call Sourcegraph_search_site()<cr>
		noremap ,ah :call Sourcegraph_jump_to_definition(1)<cr>
		noremap ,oh :call Sourcegraph_describe(1)<cr>
		noremap ,eh :call Sourcegraph_usages(1)<cr>
		noremap ,al :call Sourcegraph_jump_to_definition(2)<cr>
		noremap ,ol :call Sourcegraph_describe(2)<cr>
		noremap ,el :call Sourcegraph_usages(2)<cr>
		noremap ,aj :call Sourcegraph_jump_to_definition(3)<cr>
		noremap ,oj :call Sourcegraph_describe(3)<cr>
		noremap ,ej :call Sourcegraph_usages(3)<cr>
		noremap ,ak :call Sourcegraph_jump_to_definition(4)<cr>
		noremap ,ok :call Sourcegraph_describe(4)<cr>
		noremap ,ek :call Sourcegraph_usages(4)<cr>
	endif	
endfunction

function Disable_SG_Keybindings()
	if ! exists( "g:sg_default_keybindings" )
		let g:sg_default_keybindings = 0
	endif
	unmap ,aa
	unmap ,oo
	unmap ,ee
	unmap ,uu
	unmap ,ah
	unmap ,oh
	unmap ,eh
	unmap ,aj
	unmap ,oj
	unmap ,ej
	unmap ,ak
	unmap ,ok
	unmap ,ek
	unmap ,al
	unmap ,ol
	unmap ,el
	let g:sg_default_keybindings = 0
endfunction

"function to be called by jump..., describe, and usages
"TODO: find a way for system() to run more smoothly (open a background process
"and run the command there, call a python or perl script, etc.)
function Sourcegraph_call_src( no_examples )
	let l:sg_no_examples = ""
	let l:output = "{}\n"
	if a:no_examples
		let l:sg_no_examples = " --no-examples "
	endif
	try
		let l:output = system("src api describe --file " . 
			\expand("%:t") . ' --start-byte ' . 
			\Get_byte_offset() . l:sg_no_examples . " 2>&1")
	catch /^Vim\%((\a\+)\)=:E484/
		"catch fish specific error
		echom "If your default shell is fish, add 'set shell=/bin/bash'
			\to your .vimrc.  Otherwise, please file a bug report 
			\at https://github.com/MarkMcCaskey/sourcegraph-vim"
	endtry
	unlet l:sg_no_examples
	return l:output
endfunction

function SG_display_JSON( src_input )
	setlocal buftype=nofile
	call append(0,split(SG_parse_src(a:src_input),"\n"))
endfunction


function SG_open_buffer( buffer_position, file_name )
	let l:file_name = a:file_name
	if !exists("s:temp_buffer")
		let s:temp_buffer = "_"
	endif
	if a:file_name ==? ""
		let l:file_name = ".temp_srclib" . s:temp_buffer
	endif
	if a:buffer_position == 0
		silent execute "normal! :vsplit " . l:file_name . "\<cr>"
	elseif a:buffer_position == 1
		let l:temp_split = &splitright
		let &splitright = 0
		silent execute "normal! :vsplit " . l:file_name . "\<cr>"
		let &splitright = l:temp_split
	elseif a:buffer_position == 2
		let l:temp_split = &splitright
		let &splitright = 1
		silent execute "normal! :vsplit " . l:file_name . "\<cr>"
		let &splitright = l:temp_split
	elseif a:buffer_position == 3
		let l:temp_split = &splitbelow
		let &splitbelow = 1
		silent execute "normal! :split " . l:file_name . "\<cr>"
		let &splitbelow = l:temp_split
	elseif a:buffer_position == 4
		let l:temp_split = &splitbelow
		let &splitbelow = 0
		silent execute "normal! :split " .  l:file_name . "\<cr>"
		let &splitbelow = l:temp_split
	endif
	"temporary fix, find way to reset s:temp_buffer to prevent
	"excess _'s
	let s:temp_buffer = s:temp_buffer . "_"
	"normal! ggdG
endfunction

"returns a list containing: [location of file, starting byte]
"NOTE: exact numbers are off, need to cut off comma and the prefix before
"output is useful
function SG_jump_info( src_input )
	let l:ret = []
	let l:temp1 = filter( split( a:src_input, ',' ), 'v:val =~ "\"File\":"')
	if len(l:temp1) <= 0
		echom "No results found"
		return l:ret
	endif
	let l:temp2 = split(l:temp1[0], '"')[2]
	call add( l:ret, l:temp2 )
	let l:temp1 = filter( split( a:src_input, ',' ), 'v:val =~ "\"DefStart\":"')
	if len(l:temp1) <= 0
		echom "No results found
		return l:ret
	endif
	let l:temp2 = split(l:temp1[0], '":')[1]
	call add( l:ret, l:temp2 )
	"echo l:ret
	return ret
endfunction

function Sourcegraph_show_documentation( buffer_position )
	"let l:src_output = Sourcegraph_call_src(1)
	"let l:ret = filter( split( l:src_output, ',' ), 'v:val =~ "\"DocHTML\":"')
	"if len(l:ret) <= 0
"		echom "No documentation found"
"		return -1
"	endif
	let l:output = SG_get_JSON_val( "DocHTML" )
	call SG_open_buffer( a:buffer_position, "" )
	setlocal buftype=nofile
	"call append(0, split(l:ret[0], '"')[2])
	call append(0, l:output)
	return 1
endfunction

function SG_get_JSON_val( search_val )
	 let l:ret = SG_parse_JSON( Sourcegraph_call_src( 1 ) )
	 if ! has_key( l:ret, a:search_val )
		 return ""
	 endif
	 return l:ret[a:search_val]
endfunction

function SG_parse_JSON( input_str )
	let l:inquote = 0
	let l:multi_backslash = 0
	let l:prev_char = ""
	let l:key_name = ""
	let l:str_val = ""
	let l:key_or_val = 0
	let l:list = split( a:input_str, '\zs' )
	let l:ret = {}
	for c in l:list
		"number vals break it, need handling for str_vals without "
		if l:prev_char ==? '\' && c ==? '\'
			let l:multi_backslash = 1
			"continue
		elseif l:multi_backslash
			let l:multi_backslash = 0
			"continue
		endif
		if l:prev_char != '\' && c ==? '"'
			let l:inquote = ! l:inquote
			continue
		endif

		if ! l:inquote && c ==? ':'
			let l:key_or_val = 1
		endif
		if l:inquote || c =~ '[0-9]'
			if ! l:key_or_val
				let l:key_name = l:key_name . c
			else
				let l:str_val = l:str_val . c
			endif
		endif
		if !l:inquote && l:key_or_val && c == ','
			if l:key_name != "" && l:str_val != ""
				let l:ret[l:key_name] = l:str_val
				let l:key_name = ""
				let l:str_val = ""
				let l:key_or_val = 0
			endif
		endif
		let l:prev_char = c
	endfor
	return l:ret
endfunction


"TODO: parsing and going to relevant information in newly opened buffer
"Also, consider setting variable or checking if the buffer already exists
"before opening new ones
function Sourcegraph_jump_to_definition( buffer_position )
	let l:output = Sourcegraph_call_src( 1 )
	if l:output ==? "{}\n"
		echom "No results found"
	else
		let l:jump_list = SG_jump_info( l:output )
		if len(l:jump_list) != 2
			echom "No results found -- list too short"
			return -1
		endif
		if filereadable(l:jump_list[0])
			"open a split with file and move cursor to correct position
			call SG_open_buffer( a:buffer_position, l:jump_list[0] )
			execute "normal! gg" . (byte2line( l:jump_list[1] ) - 1) . "j\<cr>"
		else
			echom "File not found"
			return -1
		endif
	endif
endfunction

function Sourcegraph_describe( buffer_position )
	let l:output = Sourcegraph_call_src( 1 )
	if l:output ==? "{}\n"
		echom "No results found"
	else
		call SG_open_buffer( a:buffer_position, "" )
		call SG_display_JSON( l:output )
	endif
endfunction

function Sourcegraph_usages( buffer_position )
	call Sourcegraph_call_src( 0 )
endfunction


"TODO: fix errors when called from inside of TTY/place where browsers cannot
"be opened
"The error appears to be that the error message gets written over Vim, adding
"a redraw! command in this function doesn't seem to fix it, because the text
"appearing is delayed
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
	elseif executable( "sensible-browser" ) "debian-based linux
		silent execute "!sensible-browser"  l:url . " &"
	elseif executable( "xdg-open" ) "linux
		silent execute "!xdg-open" l:url . " &"
	elseif executable( "firefox" )
		silent execute "!firefox" l:url
	elseif executable( "chromium-browser" ) . " &"
		silent execute "!chromium-browser" l:url
	else 
		echom "No browser found, please submit a bug report at https://github.com/MarkMcCaskey/sourcegraph-vim"
	endif
	redraw!

	unlet l:search_string
	unlet l:base_url
	unlet l:url
endfunction
	
"TODO: add check for support on local machine by calling 'src toolchain list'
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
	execute "normal! \<esc>`q"
	return l:retval
endfunction

function SG_parse_src( in )
	let l:tab = "   "
	let l:itab = 0
	let l:ret = ""
	let l:one = split(a:in,'{\zs')
	for c in l:one
		let l:ret = l:ret . "\n" 
		let l:i = 0
		while l:i < l:itab
			let l:ret = l:ret . l:tab
			let l:i = l:i + 1	
		endwhile
		let l:ret = l:ret . c
		let l:itab = l:itab + 1
	endfor
	let l:one = split(l:ret,',\zs')
	let l:ret = ""
	for c in l:one
		let l:ret = l:ret . "\n" 
		let l:i = 0
		while l:i < l:itab
			let l:ret = l:ret . l:tab
			let l:i = l:i + 1	
		endwhile
		let l:ret = l:ret . c
	endfor
	let l:i = 1
	let l:one = split(l:ret,'}')
	let l:ret = l:one[0]
	while l:i < len(l:one)
		let l:tabulator = ""
		let l:j = 2
		while l:j < l:itab
			let l:tabulator = l:tabulator . l:tab
			let l:j = l:j + 1
		endwhile
		let l:itab = l:itab - 1
		let l:ret = l:ret . "\n" . l:tabulator . "}" . l:one[i]
		let l:i = l:i + 1
	endwhile
	unlet l:i
	unlet l:one
	unlet l:itab
	unlet l:tab
	return l:ret
endfunction


"'main': 
call SG_Keybindings()
