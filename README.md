# tide

Tmux IDE for vim

This can be used to send text from vim to tmux, in two setups:

Tmux with one pane receives all text from a non-tmux vim elsewhere, or
vim in one tmux pane can send text to the other of two panes.

## default keybindings

<F9> send visual selection
<F9> send current paragraph
<F8> send current line
<F7> send word under cursor
<F4> send section delimited by double comment characters
