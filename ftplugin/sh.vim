" Send Word is prefixed in shell scripts with 'echo $'
silent! nmap <buffer> <silent> <F7> :call TmuxSendKeysEnter('echo $' . expand("<cword>"))<CR>

" Send Word with F6 can be used to print all fields in array
silent! nmap <buffer> <silent> <F6> :call TmuxSendKeysEnter('for i in ${' . expand("<cword>") . '[@]}; do echo $i; done')<CR>

" lines are continued when ending in \
" TODO


