#!/usr/bin/env bash
# Print 'export' statements for every hidden field of a single Bitwarden item.
# Field name is the env var name, field value is its value.
set -euo pipefail

die() {
    printf 'bw-env: %s\n' "$*" >&2
    exit 1
}

usage() {
    cat >&2 <<'EOF'
usage: bw-env <item>

Prints an 'export NAME=value' line for every hidden field of the given
Bitwarden item, so that secrets can be pulled into the environment with:

    eval "$(bw-env <item>)"

<item>  item id (unambiguous) or search term. Items shared through an
        organization work as well.

The vault has to be unlocked. If it is locked, bw-env unlocks it
non-interactively when one of these is set:

    BW_PASSWORD          the master password
    BW_PASSWORD_COMMAND  a command printing the master password

and then also prints 'export BW_SESSION=...'. Without them it fails and asks
you to unlock manually.
EOF
    exit 64
}

ensure_unlocked() {
    local status password session
    status="$(bw --nointeraction status | jq -r '.status')" || die "cannot query 'bw status'"
    case "$status" in
    unlocked) return 0 ;;
    locked) ;;
    unauthenticated) die "not logged in, use 'bwu' first" ;;
    *) die "unexpected vault status: $status" ;;
    esac

    password=""
    if [ -n "${BW_PASSWORD_COMMAND:-}" ]; then
        password="$(eval "$BW_PASSWORD_COMMAND")" || die "BW_PASSWORD_COMMAND failed"
    elif [ -n "${BW_PASSWORD:-}" ]; then
        password="$BW_PASSWORD"
    fi
    [ -n "$password" ] ||
        die "vault is locked and neither BW_PASSWORD nor BW_PASSWORD_COMMAND is set, unlock it manually with 'bwu' and try again"

    session="$(BW_PASSWORD="$password" bw --nointeraction unlock --passwordenv BW_PASSWORD --raw)" ||
        die "automatic unlock failed, unlock manually with 'bwu' and try again"
    # hand the session to the caller so that later 'bw' calls stay cheap
    export BW_SESSION="$session"
    printf 'export BW_SESSION=%q\n' "$session"
}

[ "$#" -eq 1 ] || usage
case "$1" in -h | --help) usage ;; esac

ensure_unlocked

item="$(bw --nointeraction get item "$1")" || die "cannot read item '$1'"

# build everything before printing anything, so a bad field name exports nothing
exports="$(printf '%s' "$item" | jq -r '
    (.fields // [])[]
    # type 1 is a hidden field
    | select(.type == 1 and .name != null and .value != null)
    | if (.name | test("^[A-Za-z_][A-Za-z0-9_]*$")) then
        "export \(.name)=\(.value | @sh)"
      else
        error("field \(.name | tojson) is not a usable env var name")
      end
')"
[ -n "$exports" ] || die "item '$1' has no hidden fields"

printf '%s\n' "$exports"
