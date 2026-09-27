# Sends the command currently typed at the prompt to a new, detached window.
# The new window is left unnamed on purpose, so that 'automatic-rename' names
# it after whatever ends up running there.
tmux-windowizer() {
    if [[ -z ${BUFFER//[[:space:]]/} ]]; then
        return
    fi

    # The command travels in the environment instead of being typed into the new
    # window: that shell is still sourcing its startup files, and the tty would
    # echo whatever we send before its line editor takes over, printing the
    # command twice. The hook below picks it up.
    local out window_id window_index
    out=$(tmux new-window -d -P -F "#{window_id} #{window_index}" -c "$PWD" -e "TMUX_WINDOWIZER_CMD=$BUFFER") || return
    window_id=${out%% *}
    window_index=${out##* }

    # keep it recallable here as well
    print -s -- "$BUFFER"

    BUFFER=""
    CURSOR=0
    zle reset-prompt
    zle -M "sent to window $window_index"
}

zle -N tmux-windowizer

# Runs what we were sent at the first prompt, so startup files and every precmd
# hook (direnv included) have finished. From there on it is an ordinary window.
if [[ -n $TMUX_WINDOWIZER_CMD ]]; then
    _tmux_windowizer_accept() {
        # only the first prompt; deleting the widget from inside itself makes
        # zsh complain, so it just does nothing afterwards
        [[ -n $TMUX_WINDOWIZER_CMD ]] || return
        BUFFER=$TMUX_WINDOWIZER_CMD
        CURSOR=$#BUFFER
        unset TMUX_WINDOWIZER_CMD
        zle accept-line
    }
    zle -N zle-line-init _tmux_windowizer_accept
fi
