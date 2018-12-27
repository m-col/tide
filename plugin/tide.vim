"------------------------------------------------------------------"
" tide: tmux IDE
"------------------------------------------------------------------"

" load once
if exists('g:loaded_tide')
    finish
endif
let g:loaded_tide = 1

" command to prefix text
if !exists("g:tmux_cmd")
    let g:tmux_cmd = "tmux send -t .+ "
endif

" main send keys function
function! TmuxSendKeys(keys)
    let l:keys = substitute(a:keys, '^[\ ]*', '', 'g') "strip leading whitespace
    let l:keys = substitute(l:keys, '	', '    ', 'g') "make tabs spaces
    let l:keys = substitute(l:keys, ";$", '; ', 'g') "preserve trailing semicolons
    let l:keys = escape(l:keys, '\"$')
    "let l:keys = substitute(l:keys, '\', '\\\\', 'g') "escape backslashes
    "let l:keys = substitute(l:keys, '\"', '\\\"', 'g') "escape double quotes
    "let l:keys = substitute(l:keys, '!', '\!', 'g') "escape esclamation mark
    "let l:keys = escape(l:keys, '!')
    "let l:keys = substitute(l:keys, '\$', '\\\$', 'g') "escape dollar sign
    call system(g:tmux_cmd . "-l \"" . l:keys . "\"")
endfunction
function! s:TmuxSendEnter()
    call system(g:tmux_cmd . "C-m")
endfunction
function! TmuxSendKeysEnter(keys)
    call TmuxSendKeys(a:keys)
    call s:TmuxSendEnter()
endfunction

" send region between two lines
function! TmuxSendLines(top, bottom)
    if a:top > a:bottom
	call TmuxSendKeys(getline(a:top))
	call s:TmuxSendEnter()
    else
	let l:numcomments = 0
	for l:line in range(a:top, a:bottom)
	    let l:linetext = getline(l:line)
	    if empty(l:linetext)
		let l:numcomments +=1
		if l:numcomments > 1
		    continue
		endif
	    else
		let l:numcomments = 0
	    endif
	    call TmuxSendKeysEnter(l:linetext)
	endfor
    endif
endfunction

" send current paragraph
function! s:TmuxSendParagraph()
    let l:top = search('^[\ ]*$\|\%^?', 'cbnW')
    if l:top != 1
	let l:top = l:top + 1
    endif
    let l:bottom = search('^[\ ]*$\|\%$', 'nW')
    if l:bottom != line("$")
	let l:bottom = l:bottom - 1
    endif
    call TmuxSendLines(l:top, l:bottom)
endfunction

" send current section delimited by double comments
function! s:TmuxSendSection()
    " find shortest comment character
    let s:com = split(&comments, ",")
    let s:scom = substitute(s:com[0], "^.*:", '', '')
    for s:i in s:com
	let s:ncom = substitute(s:i, "^.*:", '', '')
	if len(s:ncom) < len(s:scom)
	    let s:scom = s:ncom
	endif
    endfor
    let s:header = "^\s*" . s:scom . s:scom
    let s:top = search(s:header . '\|\%^?', 'cbnW')
    let s:bottom = search(s:header . '\|\%$', 'nW')
    if s:bottom <= s:top
	let s:bottom = line('$')
    elseif s:bottom != line('$')
	let s:bottom = prevnonblank(s:bottom)
    endif
    if s:top == 0
	let s:top = 1
    endif
    call TmuxSendLines(s:top, s:bottom)
endfunction

" send visual selection
function! s:TmuxSendVisual()
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
	return ''
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    for line in lines
	call TmuxSendKeysEnter(line)
    endfor
endfunction

" command and plugin mappings
command! -nargs=+ -complete=command TmuxSendKeys call TmuxSendKeys(<q-args>)
command! -nargs=+ -complete=command TmuxSendKeysEnter call TmuxSendKeysEnter(<q-args>)
command! -nargs=0 -complete=command TmuxSendVisual call s:TmuxSendVisual()
command! -nargs=0 -complete=command TmuxSendLine call TmuxSendKeys(getline(".")) | call s:TmuxSendEnter()
command! -nargs=0 -complete=command TmuxSendParagraph call s:TmuxSendParagraph()
command! -nargs=0 -complete=command TmuxSendSection call s:TmuxSendSection()
command! -nargs=0 -complete=command -range TmuxSendLines call TmuxSendLines(<line1>, <line2>)

silent! xnoremap <unique> <silent> <script> <Plug>TmuxSendVisual :<C-u>TmuxSendVisual<CR>
silent! nnoremap <unique> <silent> <script> <Plug>TmuxSendParagraph :TmuxSendParagraph<CR>
silent! nnoremap <unique> <silent> <script> <Plug>TmuxSendLine :TmuxSendLine<CR>
silent! nnoremap <unique> <silent> <script> <Plug>TmuxSendWord :call TmuxSendKeysEnter(expand("<cword>"))<CR>
silent! nnoremap <unique> <silent> <script> <Plug>TmuxSendSection :TmuxSendSection<CR>

" default keybindings
if !exists("g:tide_no_default_keys")
    silent! xmap <unique> <silent> <F9> <Plug>TmuxSendVisual
    silent! nmap <unique> <silent> <F9> <Plug>TmuxSendParagraph
    silent! nmap <unique> <silent> <F8> <Plug>TmuxSendLine
    silent! nmap <unique> <silent> <F7> <Plug>TmuxSendWord
    silent! nmap <unique> <silent> <F4> <Plug>TmuxSendSection
endif

