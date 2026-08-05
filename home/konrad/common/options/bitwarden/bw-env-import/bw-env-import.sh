#!/usr/bin/env bash
# Create a bitwarden secure note whose hidden fields are the KEY=VALUE pairs of a .env file.
# The inverse of bw-env.
set -euo pipefail

die() {
    printf 'bw-env-import: %s\n' "$*" >&2
    exit 1
}

usage() {
    cat >&2 <<'EOF'
usage: bw-env-import <title> <notes> <env-file>

Creates a secure note named <title> with <notes> as its body, and one hidden
field per KEY=VALUE line of <env-file>: the key becomes the field name, the
value becomes the field value. Prints the id of the created item.

Read the result back with: eval "$(bw-env <title>)"

Recognized in <env-file>:

    KEY=value           blank lines and '#' comment lines are skipped
    export KEY=value    the 'export ' prefix is optional
    KEY="value"         one layer of matching quotes is removed, the rest of
    KEY='value'         the value is kept verbatim

Deliberately not supported, to avoid mangling secrets: escape sequences,
variable interpolation, inline comments after a value, and values spanning
multiple lines. Quote any value containing '#' or leading/trailing spaces;
unquoted values get their trailing whitespace trimmed.

The vault has to be unlocked, use 'bwu' first. The note is created in your
personal vault, move it to an organization afterwards with
'bw move <id> <organizationId>'.
EOF
    exit 64
}

# builds the "fields" array of the item payload
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
        [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] ||
            die "$file:$lineno: '$key' is not a usable env var name"
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

[ "$#" -eq 3 ] || usage
case "$1" in -h | --help) usage ;; esac
title="$1"
notes="$2"
env_file="$3"

[ -f "$env_file" ] || die "no such file: $env_file"

vault_status="$(bw --nointeraction status | jq -r '.status')" || die "cannot query 'bw status'"
[ "$vault_status" = "unlocked" ] || die "vault is $vault_status, use 'bwu' first"

# a duplicate name would make 'bw get item <title>' ambiguous later on
duplicates="$(bw --nointeraction list items --search "$title" |
    jq --arg n "$title" '[.[] | select(.name == $n)] | length')" || die "cannot list existing items"
[ "$duplicates" -eq 0 ] || die "an item named '$title' already exists, pick another title or delete it first"

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

encoded="$(printf '%s' "$payload" | bw --nointeraction encode)" || die "could not encode the item"
created="$(bw --nointeraction create item "$encoded")" || die "could not create the item"

# names only, never the values
printf 'bw-env-import: created "%s" with %s hidden fields: %s\n' \
    "$title" "$(jq 'length' <<<"$fields")" "$(jq -r '[.[].name] | join(", ")' <<<"$fields")" >&2
jq -r '.id' <<<"$created"
