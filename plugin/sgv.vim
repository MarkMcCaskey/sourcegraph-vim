" Vim plugin for srclib (https://srclib.org)
" Last Change: May 20 2015
" Maintainer: mmccask2@gmu.edu
" License: 

"set up
if exists( "g:sg_vim_loaded" )
	finish
endif
let g:sg_vim_loaded=7

"consider reading from configuration file or other source
let s:supported_languages={"go": "go","py": "python","java": "java","js": "nodejs","rb": "ruby"}

"ensure dependencies are satisfied
if !executable( "src" ) 
	echom "src(https://srclib.org/) is required to use this plugin"
	finish
endif

"&filetype is empty until after plugin is loaded
"Maybe autoloading the plugin can fix this?
"More research and testing needs to be done
"Current implementation requires a dot before the extension
function Supported_file()
	let l:src_out = system("src toolchain list")
	if bufname("%") ==? ""
		return 0
	endif

	"get file extension
	let l:ft_list = split(bufname("%"), "\\.")
	let l:ft = l:ft_list[len(l:ft_list)-1]

	"check if file extension is recognized
	if has_key(s:supported_languages,l:ft)
		"check if there's support locally
		if l:src_out =~ "sourcegraph.com/sourcegraph/srclib-" . s:supported_languages[l:ft]
				return 1
		endif
		return 2
	endif
	return 0
endfunction

"close plugin if editing a file not currently supported
let SG_check_supported = Supported_file()
if SG_check_supported == 0
	unlet SG_check_supported
	finish	
elseif SG_check_supported == 2
	silent echom "This language is supported by src, but you do not have it installed locally"
endif       
unlet SG_check_supported

"intialize default keybindings
"maybe this should be changed later
function SG_Keybindings()
	if ! exists( "g:sg_default_keybindings" )
		let g:sg_default_keybindings = 1
	endif
	if g:sg_default_keybindings 
		noremap <silent> ;a :call Sourcegraph_jump_to_definition()<cr>
		noremap <silent> ;ss :call Sourcegraph_describe(0)<cr>
		noremap <silent> ;dd :call Sourcegraph_usages(0)<cr>
		noremap <silent> ;f :call Sourcegraph_search_site()<cr>
		noremap <silent> ;sh :call Sourcegraph_describe(1)<cr>
		noremap <silent> ;dh :call Sourcegraph_usages(1)<cr>
		noremap <silent> ;sl :call Sourcegraph_describe(2)<cr>
		noremap <silent> ;dl :call Sourcegraph_usages(2)<cr>
		noremap <silent> ;sj :call Sourcegraph_describe(3)<cr>
		noremap <silent> ;dj :call Sourcegraph_usages(3)<cr>
		noremap <silent> ;sk :call Sourcegraph_describe(4)<cr>
		noremap <silent> ;dk :call Sourcegraph_usages(4)<cr>
		noremap <silent> ;gg :call Sourcegraph_show_documentation(0)<cr>
		noremap <silent> ;gh :call Sourcegraph_show_documentation(1)<cr>
		noremap <silent> ;gl :call Sourcegraph_show_documentation(2)<cr>
		noremap <silent> ;gj :call Sourcegraph_show_documentation(3)<cr>
		noremap <silent> ;gk :call Sourcegraph_show_documentation(4)<cr>
	endif	
endfunction

"turn off default keybindings
"this function isn't used during normal use
function Disable_SG_Keybindings()
	if ! exists( "g:sg_default_keybindings" )
		let g:sg_default_keybindings = 0
	endif
	unmap ;a
	unmap ;ss
	unmap ;dd
	unmap ;ff
	unmap ;sh
	unmap ;dh
	unmap ;sj
	unmap ;dj
	unmap ;sk
	unmap ;dk
	unmap ;sl
	unmap ;dl
	unmap ;gg
	unmap ;gh
	unmap ;gj
	unmap ;gk
	unmap ;gl
	let g:sg_default_keybindings = 0
endfunction

"function to be called by jump..., describe, and usages
"TODO: find a way for system() to run more smoothly (open a background process
"and run the command there, call a python or perl script, etc.)
"Background process may not be necessary, runs fine on modern computers
"
"Function info: takes one argument, if 1 is passed in, the no-examples flag
"will be passed to src. This function returns the string containing all the
"text from src
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
		"echom "src api describe --file " . expand("%s:t") . ' --start-byte ' . Get_byte_offset() . l:sg_no_examples
	catch /^Vim\%((\a\+)\)=:E484/
		"catch Fish specific error
		echom "If your default shell is Fish, add 'set shell=/bin/bash'
			\to your .vimrc.  Otherwise, please file a bug report 
			\at https://github.com/MarkMcCaskey/sourcegraph-vim"
	endtry
	"not sure if this is a safe thing to check for
	if match( l:output, "(exit status 1)" ) != -1
	"	echom l:output
		echom "Invalid output. Check src's output"
		return ""
	endif
	"echom l:output
	return l:output
endfunction

"This function is probably unneeded
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
function SG_jump_info( src_input )
	let l:out = SG_parse_JSON( a:src_input )
	if ! (has_key( l:out, "File" ) && has_key( l:out, "DefStart" ))
		echom "No results found"
		return []
	endif
	return [l:out["File"],l:out["DefStart"]]
endfunction

function Sourcegraph_show_documentation( buffer_position )
	"let l:output = SG_get_JSON_val( "DocHTML", 1 )
	
	"get output and check it
	let l:src_output = Sourcegraph_call_src(1)
	if l:src_output ==? ""
		echom "No documentation found"
		return -1
	endif
	let l:output = SG_parse_JSON_exp( l:src_output )

	"unsure if these are safe assumptions to make @@@
	if (! has_key (l:output, "Def")) || (! has_key(l:output["Def"], "Docs" )) || (! has_key(l:output["Def"]["Docs"][0], "Data" ))"|| (! has_key(l:output["Def"]["Docs"], "DocHTML")) 
		echom "No documentation found"
		return -1
	endif

	"open buffer and print doc info	
	call SG_open_buffer( a:buffer_position, "" )
	setlocal buftype=nofile
	let l:ret =split(l:output["Def"]["Docs"][0]["Data"], '\n')
	call append(0, l:ret)
	return 1
endfunction

"This function should either be changed or a similar function should be made
"that doesn't independently run SG_parse_JSON
function SG_get_JSON_val( search_val, examples )
	 let l:ret = SG_parse_JSON_exp( Sourcegraph_call_src( a:examples ) )
	 if ! has_key( l:ret, a:search_val )
		 return ""
	 endif
	 return l:ret[a:search_val]
endfunction

function SG_parse_JSON( input_str )
	let l:inquote = 0
	let l:prev_char = ""
	let l:key_name = ""
	let l:str_val = ""
	let l:key_or_val = 0
	let l:list = split( a:input_str, '\zs' )
	let l:ret = {}
	for c in l:list
		if c ==? '\'
			let l:prev_char = c
			continue
		endif
		if l:prev_char ==? '\'
			silent execute "normal! :let c = " . '"\' . c . "\"\<cr>"
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

function Sourcegraph_jump_to_definition()
	let l:src_output = Sourcegraph_call_src( 1 )
	if l:src_output ==? "{}\n"
		echom "No results found"
	else
		let l:jump_list = SG_jump_info( l:src_output )
		if len(l:jump_list) != 2
			return -1
		endif
		if filereadable(l:jump_list[0])
			"open a split with file and move cursor to correct position
			silent execute "normal! :edit " . l:jump_list[0] . "\<cr>"
			silent execute "normal! gg" . (byte2line( l:jump_list[1] ) - 1 ) . "j\<cr>"
		else
			echom "File not found"
			return -1
		endif
	endif
endfunction

"This function expects a new version of src, see comment inside
function Sourcegraph_describe( buffer_position )
	let l:raw_src_output = Sourcegraph_call_src( 0 )
	if l:raw_src_output == ""
		return -1
	endif
	let l:src_output = SG_parse_JSON_exp( l:raw_src_output )

	if ! has_key( l:src_output, "Def" )
		echom "No results found"
		return -1
	endif
	if ! has_key( l:src_output["Def"], "UnitType" ) 
		echom "No results found"
		return -1
	endif	
	echom string(l:src_output)
	let l:unit = l:src_output["Def"]["UnitType"]
	call SG_open_buffer( a:buffer_position, "" )
	"temporarily add -t def
	"This system call expects a newer version of src (TODO: research this
	"and figure out exactly what should be done and add handling for all
	"versions of src that may be out there)
	let l:out = system("src fmt -u " . l:unit . " --object-type=Def " . " --object=" . l:raw_src_output )
	echom "src fmt -u " . l:unit . " --object-type=Def " . " --object=" . l:raw_src_output 
	call append(0,l:out)
	return 1
endfunction

function Sourcegraph_usages( buffer_position )
	let l:src_output = Sourcegraph_call_src(0)
	"ensure output is valid
	if l:src_output == ""
		return -1
	endif

	let l:output = SG_parse_JSON_exp( l:src_output )
	if l:output ==? {} || ! has_key( l:output, "Examples" ) || empty(l:output["Examples"])
		echom "No results found"
		return -1
	endif
	call SG_open_buffer( a:buffer_position, "" )
	"need to parse the output
	call append(0,join(l:output["Examples"],'\n'))
	return 1
endfunction

"experimental parse JSON function
function SG_parse_JSON_exp( input )
	"remove new lines
	let l:ret = join(split(a:input,"\n"))

	"replace true, false, and null with numerical values
	let l:ret = join(split(l:ret,'true'),'1')
	let l:ret = join(split(l:ret,'false'),'0')
	let l:ret = join(split(l:ret,'null'),0)

	"this line was to parse the string into a dictionary
	"protect against bad input
	echo l:ret
	silent execute "normal! :let l:retl = " . l:ret . "\<cr>"
	return l:retl
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
	let l:path = SG_get_JSON_val("Unit",0)
	if l:path ==? ""
		echom "No results found"
		return -1
	endif
	let l:search_string = l:path . '+' . @a

	echom l:search_string

	"try opening with browser
	"TODO: find better way to open in the background
	let l:url = '"' . l:base_url . "search?q=" . l:search_string . '"'
	if executable( 0 ) "mac OS X and Linux
		"open is a keyword in VimL
		"TODO: find way to call open
		":call system( "open " . l:url . " &" )
		silent execute "!open " l:url . " &"
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
		return 0
	endif
	redraw!
	return 1
endfunction
	

"Returns the byte of the first letter of the word the cursor is on
function Get_byte_offset()
	"added viw so that if called on first letter it stays on the same word
	execute "normal! mqviwb"
	let l:retval = line2byte(line("."))+col(".")
	execute "normal! \<esc>`q"
	return l:retval
endfunction


"Note this function just formats src output, needs to be renamed
"This function needs to be redone, method of indentation doesn't work on large
"files and is hard to maintain
"NOTE: src fmt replaces this
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
	return l:ret
endfunction


"'main': 
call SG_Keybindings()
