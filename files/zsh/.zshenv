# sourced every time

# hardcode homebrew prefix to speed things up
# used only on mac
export BREW_PREFIX="/usr/local"
# ZSH paths to be used in functions or scripts
if [ "$(uname)" = "Darwin" ]; then
    export ZSH_VENDOR_COMPLETIONS="$BREW_PREFIX/share/zsh/site-functions"
elif [ "$(uname)" = "Linux" ]; then
	if [ -f "/etc/arch-release" ]; then
        export ZSH_VENDOR_COMPLETIONS='/usr/share/zsh/site-functions'
	elif [ -f "/etc/debian_version" ]; then
        export ZSH_VENDOR_COMPLETIONS='/usr/share/zsh/vendor-completions'
	fi
fi
# custom functions

zfunc_completions_helper() {
    local generate_command="$1"
    local completions_filename="$2"
    local zfunc="${HOME}/.zfunc"

    if [ ! -f $ZSH_VENDOR_COMPLETIONS/$completions_filename ]; then
        # keep || true in case some of these programs are not in path (fail silently)
        eval "$generate_command" > "${zfunc}/$completions_filename" || true
    else
        # remove if exists locally because it is already provided by package manager
        rm -f ${zfunc}/$completions_filename
    fi
}

# custom autocompletion
# generate functions and store them for autoload by zsh
generate_completions() {
    # python
    zfunc_completions_helper "pip3 completion --zsh" _pip3
    zfunc_completions_helper "poetry completions zsh" _poetry
    # rust
    zfunc_completions_helper "rustup completions zsh" _rustup
    zfunc_completions_helper "rustup completions zsh cargo" _cargo
    # kubernetes
    zfunc_completions_helper "kubectl completion zsh" _kubectl
    zfunc_completions_helper "helm completion zsh" _helm
    zfunc_completions_helper "k3d completion zsh" _k3d
    zfunc_completions_helper "kind completion zsh" _kind
    zfunc_completions_helper "flux completion zsh" _flux
    # earthly
    zfunc_completions_helper "earthly bootstrap --source zsh" _earthly
    # force compinit
    rm -f ${HOME}/.zcompdump
    echo "completions generated; you may need to restart your shell"
}

load_bash_completions() {
    # specific bash-completions need to be called here
    if command -v pipx &>/dev/null; then
        if [ "$(uname)" = "Darwin" ]; then
            source "$BREW_PREFIX/etc/bash_completion.d/pipx"
        elif [ "$(uname)" = "Linux" ]; then
            eval "$(register-python-argcomplete pipx)"
        fi
    fi
    if command -v az &>/dev/null; then
        if [ "$(uname)" = "Darwin" ]; then
            source "$BREW_PREFIX/etc/bash_completion.d/az"
        elif [ "$(uname)" = "Linux" ]; then
            if [ -f "/etc/arch-release" ]; then
                source "/usr/share/bash-completion/completions/az"
            elif [ -f "/etc/debian_version" ]; then
                source "/etc/bash_completion.d/azure-cli"
            fi
        fi
    fi
}


weather() {
    local param="$1"
    if [ -z "$param" ]; then
        curl "wttr.in/?F"
    else
        curl "wttr.in/${param}?F"
    fi
}

timezsh() {
  local shell=${1-$SHELL}
  for i in $(seq 1 10); do time $shell -i -c exit; done
}

# fix for tmux ssh socket
fix_ssh_auth_sock() {
    # (On) reverses globbing order
    # https://unix.stackexchange.com/a/27400
    for tsock in /tmp/ssh*/agent*(On); do
        if [ -O "$tsock" ]; then
            sock=$tsock
            break
        fi
    done
    if [ -n "$sock" ]; then
        export SSH_AUTH_SOCK="$sock"
        echo "New socket: $sock"
    else
        echo "Could not find appropriate socket :("
        unset SSH_AUTH_SOCK
    fi
}

# magic to prune local branches that are not on remote
git-prune-local-branches() {
    git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -d
}

# for GPG agent
function _gpg-agent_update-tty_preexec {
  gpg-connect-agent updatestartuptty /bye &> /dev/null
}

# platform dependent
if [ "$(uname)" = "Darwin" ]; then
    # gnu coreutils by default instead of BSD-based that macos provides, may cause problems later but I want that!
    export PATH="$BREW_PREFIX/opt/coreutils/libexec/gnubin:${PATH}"
    export MANPATH="$BREW_PREFIX/opt/coreutils/libexec/gnuman:${MANPATH}"
    # hardcode as nvim. Can't do it interactively because it will be loaded later than this script (from brew)
    export EDITOR='nvim'
fi

export LANG="en_US.UTF-8"
export LC_CTYPE="$LANG"
export LC_ALL="$LANG"

# XDG structure
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# editors and stuff
if [ -z "$EDITOR" ]; then
    if command -v nvim &>/dev/null; then
        export EDITOR='nvim'
    elif command -v vim &>/dev/null; then
        export EDITOR='nvim'
    elif command -v vi &>/dev/null; then
        export EDITOR='vi'
    else
        echo "Warning! No proper editor (nvim, vim or vi) found."
    fi
fi
export VISUAL="$EDITOR"
export GIT_EDITOR="$EDITOR"
export DIFFPROG="$EDITOR -d"

# set favorite pager
export PAGER="less -FirSwX"
export MANPAGER="less -FirSwX"


# docker buildkit feature
export DOCKER_BUILDKIT=1

# krew (kubectl package manager)
export PATH="$PATH:$HOME/.krew/bin"
# Gopath
export GOPATH="$HOME/.go"
# go binaries
export PATH="$GOPATH/bin:$PATH"
# rust binaries
export PATH="$HOME/.cargo/bin:$PATH"
# custom binaries in PATH
export PATH="$HOME/.local/bin:$PATH"
