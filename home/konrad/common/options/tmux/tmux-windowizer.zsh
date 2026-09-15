# Sends the command currently typed at the prompt to a new, detached window.
# The new window is left unnamed on purpose, so that 'automatic-rename' names
# it after whatever ends up running there.
tmux-windowizer() {
    if [[ -z $TMUX ]]; then
        zle -M "not inside tmux"
        return
    fi
    if [[ -z ${BUFFER//[[:space:]]/} ]]; then
        return
    fi

    local out window_id window_index
    out=$(tmux new-window -d -P -F "#{window_id} #{window_index}" -c "$PWD") || return
    window_id=${out%% *}
    window_index=${out##* }

    # -l so that words like 'Enter' are not interpreted as key names
    tmux send-keys -t "$window_id" -l -- "$BUFFER"
    tmux send-keys -t "$window_id" Enter

    # keep it recallable here as well
    print -s -- "$BUFFER"

    BUFFER=""
    CURSOR=0
    zle reset-prompt
    zle -M "sent to window $window_index"
}

zle -N tmux-windowizer
