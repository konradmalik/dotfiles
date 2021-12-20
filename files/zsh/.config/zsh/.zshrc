# Sourced on every interactive shell
#
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

# Useful Functions
source "$ZDOTDIR/functions"

zsh_add_file "completions"
zsh_add_file "aliases"
zsh_add_file "gpg-agent"
zsh_add_file "vi-mode"

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

# starship prompt. Should be very close to the end of the file
eval "$(starship init zsh)"

# source zsh plugins that vary by platform
# should be last
zsh_add_file "plugins"
