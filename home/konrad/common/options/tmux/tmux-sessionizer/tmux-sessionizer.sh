#!/usr/bin/env bash

tmux_script_name=".tmux.sh"

# plain ANSI codes: the terminal palette is base16, so these follow the theme
esc=$'\033'
reset="${esc}[0m"
bold="${esc}[1m"
dim="${esc}[2m"
green="${esc}[32m"
yellow="${esc}[33m"
blue="${esc}[34m"
magenta="${esc}[35m"
cyan="${esc}[36m"

session_name() {
    basename "$1" | tr . _
}

heading() {
    printf '%s\n' "${bold}${magenta}▌ $1${reset}"
}

preview() {
    local dir=$1
    local name
    name=$(session_name "$dir")

    heading "SELECTED"
    printf '  %s\n' "${bold}${blue}${name}${reset}"
    printf '  %s\n' "${dim}${dir/#"$HOME"/\~}${reset}"
    if tmux has-session -t="$name" 2>/dev/null; then
        printf '  %s\n' "${green}✔ exists, will switch to it${reset}"
    elif [[ -f "$dir/$tmux_script_name" ]]; then
        printf '  %s\n' "${yellow}✚ new, will run ${tmux_script_name}${reset}"
    else
        printf '  %s\n' "${yellow}✚ new${reset}"
    fi
    printf '\n'

    local sessions
    sessions=$(tmux list-sessions -F $'#{session_name}\t#{session_windows}\t#{?session_attached,1,}' 2>/dev/null)
    if [[ -z $sessions ]]; then
        heading "ACTIVE SESSIONS"
        printf '  %s\n' "${dim}none${reset}"
        return
    fi

    heading "ACTIVE SESSIONS ($(printf '%s\n' "$sessions" | wc -l | tr -d ' '))"
    local s windows attached marker color note
    while IFS=$'\t' read -r s windows attached; do
        note=""
        if [[ $s == "$name" ]]; then
            marker="●"
            color="${bold}${green}"
        elif [[ -n $attached ]]; then
            marker="◆"
            color="${cyan}"
        else
            marker="○"
            color=""
        fi
        [[ -n $attached ]] && note=" attached"
        printf '  %b%s %-24s%b %s\n' \
            "$color" "$marker" "$s" "$reset" \
            "${dim}${windows}w${note}${reset}"
    done <<<"$sessions"
}

if [[ $1 == "--preview" ]]; then
    preview "$2"
    exit 0
fi

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(fd . --type d --min-depth 3 --max-depth 3 ~/Code | fzf-tmux -p 80%,80% -- \
        --preview="\"$0\" --preview {}" \
        --preview-window="up,60%,border-bottom")
fi

if [[ -z $selected ]]; then
    # nothing selected
    exit 0
fi

selected_name=$(session_name "$selected")

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    # if not such session, create
    # (decrement SHLVL so the new session's shell lands at the same level
    # as a plain tmux session instead of one higher)
    SHLVL=$((SHLVL - 1)) tmux new-session -ds "$selected_name" -c "$selected"

    # try to execute script if exists
    if [ -f "$selected/$tmux_script_name" ]; then
        "$selected/$tmux_script_name" "$selected_name"
    fi
fi

# at this point we have a session, now figure out how to connect

if [[ -z $TMUX ]]; then
    # not in tmux, just attach
    tmux attach -t "$selected_name"
else
    # inside tmux, just switch
    tmux switch-client -t "$selected_name"
fi
