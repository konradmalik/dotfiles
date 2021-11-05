# Sourced on every interactive shell

# depending on platform, add more
if [ "$(uname)" = "Darwin" ]; then
    fpath+="$BREW_PREFIX/share/zsh-completions"
elif [ "$(uname)" = "Linux" ]; then
    if [ -f "/etc/arch-release" ]; then
        # arch has it already done in a proper dir
    elif [ -f "/etc/debian_version" ]; then
        fpath+="/usr/local/share/zsh/plugins/zsh-completions/src"
    fi
fi
# local user folder for custom autocompletion functions
fpath+="${HOME}/.zfunc"
# homebrew
fpath+="$BREW_PREFIX/share/zsh/site-functions"

# autocompletion
autoload -Uz compinit; compinit
# bash-complatible autocompletion
autoload -Uz bashcompinit; bashcompinit
# specific bash-completions need to be called here
load_bash_completions
# use cache
zstyle ':completion::complete:*' use-cache 1
# autocompletion menu
zstyle ':completion:*' menu select
# aliases autocompletion
setopt COMPLETE_ALIASES
# autocomplete with sudo
zstyle ':completion::complete:*' gain-privileges 1
# case insensitive https://superuser.com/questions/1092033/how-can-i-make-zsh-tab-completion-fix-capitalization-errors-for-directories-and
# case-insensitive matching only if there are no case-sensitive matches add '', e.g.
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
# display completer while waiting
zstyle ":completion:*" show-completer true

# Save most-recent X lines
HISTSIZE=100000
SAVEHIST=100000
HISTFILE="$HOME/.zsh_history"
# share history between sessions
setopt share_history
# save each entry to history (as opposed to on shell exit)
setopt INC_APPEND_HISTORY
# Delete old recorded entry if new entry is a duplicate.
setopt HIST_IGNORE_ALL_DUPS
# Do not display a line previously found.
setopt HIST_FIND_NO_DUPS
# disable saving commands starting with space to history
setopt HIST_IGNORE_SPACE
# Remove superfluous blanks before recording entry.
setopt HIST_REDUCE_BLANKS

# enable directories stack
setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

# vimode
bindkey -v
## Reduce latency when pressing <Esc>
export KEYTIMEOUT=1

# vi keys for menu selection
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Editing Command Lines In Vim
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

## Restore some keymaps removed by vim keybind mode
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
#bindkey '\e[3~' delete-char

# make gpg-agent prompt for password propery even in cli-only environments
export GPG_TTY=$(tty)

# For a full list of active aliases, run `alias`.
# to run command that is shadowed by an alias run (for example): \ls
# allow sudo with aliases
alias sudo='sudo '

alias vim='nvim'
alias vi='nvim'

# cat on steroids
alias cat='bat'

# colorize stuff
alias ls='exa --icons'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias grep='grep --color=auto'
alias ip='ip --color'

# faster navigation
alias ..='cd ..'
alias ...='cd ../..'

# safety measures
alias rm='rm -i'
alias mv='mv -i'

# modern watch
alias watch='viddy'

# csv pretty print
alias tv='tidy-viewer'

# git
alias ga="git add"
alias gc="git commit"
alias gco="git checkout"
alias gcp="git cherry-pick"
alias gd="git diff"
alias gl="git graph"
alias gp="git push"
alias gs="git status"
alias gt="git tag"

# directory stack movement
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

# aliases etc that vary by platform:
if [ "$(uname)" = "Darwin" ]; then
    alias mac-upgrade='brew update && brew upgrade && brew upgrade --cask && generate_completions'
    alias mac-clean='brew cleanup'
    alias touchbar-restart='sudo pkill TouchBarServer'
    alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
elif [ "$(uname)" = "Linux" ]; then
	if [ -f "/etc/arch-release" ]; then
		alias arch-upgrade='yay -Syu --sudoloop --removemake --devel --nocleanmenu --nodiffmenu --noeditmenu --noupgrademenu && flatpak update --noninteractive && generate_completions'
		alias arch-clean='yay -Sc --noconfirm'
	elif [ -f "/etc/debian_version" ]; then
		alias ubuntu-upgrade='sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo snap refresh && generate_completions'
		alias ubuntu-clean='sudo apt clean'
	fi
    # pbcopy and pbpaste just like in osx
    if [ "$(loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type)" = "Type=x11" ]; then
        # x11
        alias pbcopy='xclip'
        alias pbpaste='xclip -o'
    else
        # wayland
        alias pbcopy='wl-copy'
        alias pbpaste='wl-paste'
    fi
    # open from osx
    alias open='xdg-open'
fi

# other programs inits (lazy load where possible)
# keep this as an example for the future
# pyenv() {
#     unfunction "$0"
#     eval "$(pyenv init -)"
#     $0 "$@"
# }
# to record "cd" history, zoxide cannot be lazy
eval "$(zoxide init zsh)"
# enable asdf
. $HOME/.asdf/asdf.sh
# Hook direnv into your shell.
eval "$(asdf exec direnv hook zsh)"
# A shortcut for asdf managed direnv.
direnv() { asdf exec direnv "$@"; }
# broot
autoload -Uz br

# source fzf functionality if available
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# starship prompt. Should be very close to the end of the file
eval "$(starship init zsh)"

# source zsh plugins that vary by platform
# should be last
if [ "$(uname)" = "Darwin" ]; then
    source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [ "$(uname)" = "Linux" ]; then
	if [ -f "/etc/arch-release" ]; then
        source "/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
        source "/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	elif [ -f "/etc/debian_version" ]; then
        source "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        source "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
	fi
fi
