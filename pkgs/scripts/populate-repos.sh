#!/bin/sh
set -eu

# Clones the repos you can see under the namespace matching the current dir, over ssh.
# Layout: $CODE_ROOT/<host>/<namespace...>/<repo>, e.g. ~/Code/gitlab.com/group/subgroup.
# Uses gh (github) or glab (gitlab), whichever is logged in to the host. On gitlab the dir
# can also be just <host>, to clone every project you are a member of.

usage() {
    echo "usage: $(basename "$0") -n|-c [-a] [-j jobs]"
    echo "  -n  dry run, only print what would be cloned"
    echo "  -c  clone the missing repos"
    echo "  -a  include archived repos"
    echo "  -j  parallel clones (default 4)"
    echo "CODE_ROOT (default ~/Code) must contain the current dir as <host>[/<namespace...>]"
}

mode=""
archived=false
jobs=4
while getopts "ncaj:h" opt; do
    case "$opt" in
    n) mode=dry-run ;;
    c) mode=clone ;;
    a) archived=true ;;
    j) jobs="$OPTARG" ;;
    h) usage && exit 0 ;;
    *) usage >&2 && exit 1 ;;
    esac
done
if [ -z "$mode" ]; then
    usage >&2
    exit 1
fi

root="$(cd "${CODE_ROOT:-$HOME/Code}" && pwd -P)"
cwd="$(pwd -P)"
case "$cwd/" in
"$root"/*/) rel="${cwd#"$root"/}" ;;
*)
    echo "$cwd is not a <host>[/<namespace>] dir under $root" >&2
    exit 1
    ;;
esac
host="${rel%%/*}"
namespace="${rel#"$host"}"
namespace="${namespace#/}"

# both print "<path relative to the current dir> <ssh clone url>" per repo

list_github() {
    if [ -z "$namespace" ]; then
        echo "github needs an owner dir, e.g. $root/$host/<owner>" >&2
        return 1
    fi
    set -- --limit 100000 --json name,sshUrl --jq '.[] | "\(.name) \(.sshUrl)"'
    $archived || set -- "$@" --no-archived
    GH_HOST="$host" gh repo list "$namespace" "$@"
}

list_gitlab() {
    enc="$(printf '%s' "$namespace" | sed 's|/|%2F|g')"
    query="per_page=100&include_subgroups=true&with_shared=false"
    $archived || query="$query&archived=false"
    # namespace is either empty (whole host), a group (possibly nested) or a user
    if [ -z "$namespace" ]; then
        json="$(glab api --hostname "$host" --paginate "projects?$query&membership=true")"
    elif ! json="$(glab api --hostname "$host" --paginate "groups/$enc/projects?$query" 2>/dev/null)"; then
        json="$(glab api --hostname "$host" --paginate "users/$enc/projects?$query")"
    fi
    # (printf, not echo: sh's echo expands escapes in descriptions and breaks the json)
    printf '%s\n' "$json" | jq -r --arg ns "${namespace:+$namespace/}" \
        '.[] | "\(.path_with_namespace | ltrimstr($ns)) \(.ssh_url_to_repo)"'
}

if gh auth status --hostname "$host" >/dev/null 2>&1; then
    repos="$(list_github)"
elif glab auth status --hostname "$host" >/dev/null 2>&1; then
    repos="$(list_gitlab)"
else
    echo "not logged in to $host with gh or glab" >&2
    exit 1
fi

if [ -z "$repos" ]; then
    echo "no repos found for $rel" >&2
    exit 1
fi

missing="$(echo "$repos" | while read -r path url; do
    [ -e "$path" ] || echo "$path $url"
done)"

total="$(echo "$repos" | wc -l | tr -d ' ')"
if [ -z "$missing" ]; then
    echo "all $total repos already present"
    exit 0
fi
echo "$(echo "$missing" | wc -l | tr -d ' ') of $total repos missing"

if [ "$mode" = dry-run ]; then
    echo "$missing" | while read -r path url; do echo "would clone $url -> $path"; done
    exit 0
fi

# shellcheck disable=SC2016
echo "$missing" | xargs -P "$jobs" -L 1 sh -c 'git clone --quiet "$1" "$0" && echo "cloned $0"'
