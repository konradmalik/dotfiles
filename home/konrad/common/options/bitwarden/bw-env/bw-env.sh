#!/usr/bin/env bash
# Move secrets between the hidden fields of a bitwarden item and the environment.
set -euo pipefail

# single source of truth for what a usable env var name looks like,
# shared between the shell and the jq programs below
readonly ENV_NAME_RE='^[A-Za-z_][A-Za-z0-9_]*$'

die() {
    printf 'bw-env: %s\n' "$*" >&2
    exit 1
}

warn() {
    printf 'bw-env: %s\n' "$*" >&2
}

usage() {
    cat >&2 <<'EOF'
usage: bw-env get <item>
       bw-env import <title> <notes> <env-file>
       bw-env export [-f] <item> <env-file>

Secrets live as hidden fields of a single bitwarden item: the field name is the
env var name, the field value is its value.

get     Print an 'export NAME=value' line per hidden field of <item>. Nothing
        is exported until the caller evaluates them, a child process cannot
        change its parent's environment:

            eval "$(bw-env get <item>)"

import  Create a secure note named <title>, with <notes> as its body and one
        hidden field per KEY=VALUE line of <env-file>. Prints the new item id.
        The note is created in your personal vault, share it afterwards with
        'bw move <id> <organizationId>'.

        Recognized in <env-file>:

            KEY=value           blank lines and '#' comment lines are skipped
            export KEY=value    the 'export ' prefix is optional
            KEY="value"         one layer of matching quotes is removed, the
            KEY='value'         rest of the value is kept verbatim

        Deliberately unsupported, to avoid mangling secrets: escape sequences,
        variable interpolation, inline comments after a value, and values
        spanning several lines. Quote any value containing '#' or leading or
        trailing spaces; unquoted values get their trailing whitespace trimmed.

export  Write one KEY='value' line per hidden field of <item> to <env-file>,
        with mode 0600. Refuses to touch an existing file without -f. Values
        are quoted so that the result is both shell-sourceable and readable
        back by 'bw-env import'; a value that mixes an apostrophe with one of
        " \ $ ` , or spans several lines, cannot be expressed that way and is
        reported instead of written out mangled. Prefer 'get' over this, a .env
        file is a plaintext copy of your secrets, so keep it out of git.

<item>  item id (unambiguous) or search term. Items shared through an
        organization work as well.

The vault has to be unlocked. If it is locked, bw-env unlocks it
non-interactively when one of these is set:

    BW_PASSWORD          the master password
    BW_PASSWORD_COMMAND  a command printing the master password

For 'get' the fresh session key is printed along with the secrets, so that
later 'bw' calls in that shell are cheap. Without either variable bw-env fails
and asks you to unlock manually with 'bwu'.
EOF
    exit 64
}

# $1: whether a fresh session key may go to stdout ("emit-session") or not.
# unlocking invalidates every previous session key, hence the warning.
ensure_unlocked() {
    local session_to_stdout="$1"
    local bw_json vault_status password session
    bw_json="$(bw --nointeraction status)" || die "cannot query 'bw status'"
    vault_status="$(jq -r '.status' <<<"$bw_json")" || die "cannot parse 'bw status'"
    case "$vault_status" in
    unlocked) return 0 ;;
    locked) ;;
    unauthenticated) die "not logged in, use 'bwu' first" ;;
    *) die "unexpected vault status: $vault_status" ;;
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
    [ -n "$session" ] || die "unlock returned an empty session key"
    export BW_SESSION="$session"
    if [ "$session_to_stdout" = "emit-session" ]; then
        printf 'export BW_SESSION=%q\n' "$session"
    else
        warn "unlocked the vault, any BW_SESSION held by another shell is now invalid"
    fi
}

fetch_item() {
    bw --nointeraction get item "$1" || die "cannot read item '$1'"
}

cmd_get() {
    [ "$#" -eq 1 ] || usage
    local item exports

    ensure_unlocked emit-session
    item="$(fetch_item "$1")"

    exports="$(jq -r --arg re "$ENV_NAME_RE" '
        (.fields // [])[]
        # type 1 is a hidden field
        | select(.type == 1 and .name != null and .value != null)
        | if (.name | test($re)) then
            "export \(.name)=\(.value | @sh)"
          else
            error("field \(.name | tojson) is not a usable env var name")
          end
    ' <<<"$item")"
    [ -n "$exports" ] || die "item '$1' has no hidden fields"

    printf '%s\n' "$exports"
}

# builds the "fields" array of an item payload out of a .env file
parse_env() {
    local file="$1"
    local -A seen=()
    local fields='[]'
    local lineno=0 line key value

    while IFS= read -r line || [ -n "$line" ]; do
        lineno=$((lineno + 1))
        line="${line%$'\r'}"
        # trim leading whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        [ -n "$line" ] || continue
        case "$line" in
        '#'*) continue ;;
        'export '*)
            line="${line#export }"
            line="${line#"${line%%[![:space:]]*}"}"
            ;;
        esac

        key="${line%%=*}"
        value="${line#*=}"
        [ "$key" != "$line" ] || die "$file:$lineno: no '=' in this line"
        # trim whitespace around the key
        key="${key#"${key%%[![:space:]]*}"}"
        key="${key%"${key##*[![:space:]]}"}"
        [[ "$key" =~ $ENV_NAME_RE ]] || die "$file:$lineno: '$key' is not a usable env var name"
        [ -z "${seen[$key]:-}" ] || die "$file:$lineno: '$key' was already set on line ${seen[$key]}"
        seen[$key]="$lineno"

        case "$value" in
        '"'*'"') value="${value#\"}" value="${value%\"}" ;;
        "'"*"'") value="${value#\'}" value="${value%\'}" ;;
        '"'* | "'"*) die "$file:$lineno: unterminated quote, multi-line values are not supported" ;;
        # trailing whitespace is trimmed only when the value is not quoted
        *) value="${value%"${value##*[![:space:]]}"}" ;;
        esac

        fields="$(jq -c --arg n "$key" --arg v "$value" \
            '. + [{name: $n, value: $v, type: 1, linkedId: null}]' <<<"$fields")"
    done <"$file"

    [ "$fields" != '[]' ] || die "$file: no KEY=VALUE lines found"
    printf '%s' "$fields"
}

cmd_import() {
    [ "$#" -eq 3 ] || usage
    local title="$1" notes="$2" env_file="$3"
    local duplicates fields payload encoded created

    [ -f "$env_file" ] || die "no such file: $env_file"

    ensure_unlocked no-session

    # a duplicate name would make 'bw-env get <title>' ambiguous later on
    duplicates="$(bw --nointeraction list items --search "$title" |
        jq --arg n "$title" '[.[] | select(.name == $n)] | length')" || die "cannot list existing items"
    [ "$duplicates" -eq 0 ] ||
        die "an item named '$title' already exists, pick another title or delete it first"

    fields="$(parse_env "$env_file")"

    payload="$(jq -cn --arg name "$title" --arg notes "$notes" --argjson fields "$fields" '{
        organizationId: null,
        collectionIds: null,
        folderId: null,
        # type 2 is a secure note
        type: 2,
        name: $name,
        notes: $notes,
        favorite: false,
        fields: $fields,
        login: null,
        secureNote: { type: 0 },
        card: null,
        identity: null,
        reprompt: 0
    }')"

    encoded="$(bw --nointeraction encode <<<"$payload")" || die "could not encode the item"
    created="$(bw --nointeraction create item "$encoded")" || die "could not create the item"

    # names only, never the values
    warn "created \"$title\" with $(jq 'length' <<<"$fields") hidden fields: $(jq -r '[.[].name] | join(", ")' <<<"$fields")"
    jq -r '.id' <<<"$created"
}

cmd_export() {
    local force=""
    case "${1:-}" in
    -f | --force)
        force=1
        shift
        ;;
    esac
    [ "$#" -eq 2 ] || usage
    local item_ref="$1" env_file="$2"
    local env_dir item lines tmp

    [ -n "$force" ] || [ ! -e "$env_file" ] || die "$env_file already exists, pass -f to overwrite it"
    env_dir="$(dirname "$env_file")"
    [ -d "$env_dir" ] || die "no such directory: $env_dir"

    ensure_unlocked no-session
    item="$(fetch_item "$item_ref")"

    # built in full before anything is written, so a value we cannot express
    # aborts the whole export instead of leaving half a file behind
    lines="$(jq -r --arg re "$ENV_NAME_RE" '
        (.fields // [])[]
        # type 1 is a hidden field
        | select(.type == 1 and .name != null and .value != null)
        | .name as $n | .value as $v
        | if ($n | test($re) | not) then
            error("field \($n | tojson) is not a usable env var name")
          elif ($v | contains("\n")) then
            error("\($n) has a multi-line value, a .env file cannot carry it")
          elif (($v | contains("'"'"'")) | not) then
            "\($n)='"'"'\($v)'"'"'"
          elif ((($v | contains("\"")) or ($v | contains("\\")) or ($v | contains("$")) or ($v | contains("`"))) | not) then
            "\($n)=\"\($v)\""
          else
            error("\($n) mixes an apostrophe with one of \" \\ $ `, this .env subset cannot represent it")
          end
    ' <<<"$item")"
    [ -n "$lines" ] || die "item '$item_ref' has no hidden fields"

    # mktemp gives us 0600, and the rename keeps a failed export from clobbering anything
    tmp="$(mktemp "$env_dir/.bw-env-export.XXXXXX")"
    trap 'rm -f "$tmp"' EXIT
    {
        printf '# written by bw-env export from the bitwarden item %s\n' "${item_ref//$'\n'/ }"
        printf '%s\n' "$lines"
    } >"$tmp"
    mv "$tmp" "$env_file"
    trap - EXIT

    # names only, never the values
    warn "wrote $(printf '%s\n' "$lines" | wc -l | tr -d ' ') secrets to $env_file (mode 0600): $(jq -r '[(.fields // [])[] | select(.type == 1) | .name] | join(", ")' <<<"$item")"
}

command="${1:-}"
[ "$#" -eq 0 ] || shift
case "$command" in
get) cmd_get "$@" ;;
import) cmd_import "$@" ;;
export) cmd_export "$@" ;;
-h | --help | '') usage ;;
*) die "unknown command '$command', expected get, import or export" ;;
esac
