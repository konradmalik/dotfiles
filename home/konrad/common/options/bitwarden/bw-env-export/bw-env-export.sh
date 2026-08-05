#!/usr/bin/env bash
# Write the hidden fields of a bitwarden item to a .env file.
# The inverse of bw-env-import.
set -euo pipefail

die() {
    printf 'bw-env-export: %s\n' "$*" >&2
    exit 1
}

usage() {
    cat >&2 <<'EOF'
usage: bw-env-export [-f] <item> <env-file>

Writes one KEY='value' line per hidden field of the given bitwarden item to
<env-file>, created with mode 0600. Refuses to touch an existing file unless
-f is passed.

<item>  item id (unambiguous) or search term.

Values are single quoted, or double quoted when they contain an apostrophe, so
that the result is both shell-sourceable ('set -a; . ./.env') and readable back
by bw-env-import. A value that mixes an apostrophe with one of " \ $ ` , or one
spanning several lines, cannot be expressed this way and is reported as an
error instead of being written out mangled.

The vault has to be unlocked, use 'bwu' first.

Prefer 'eval "$(bw-env <item>)"' over this. A .env file is a plaintext copy of
your secrets, so keep it out of git.
EOF
    exit 64
}

case "${1:-}" in
-h | --help) usage ;;
-f | --force)
    force=1
    shift
    ;;
esac
[ "$#" -eq 2 ] || usage
item_ref="$1"
env_file="$2"

[ -n "${force:-}" ] || [ ! -e "$env_file" ] || die "$env_file already exists, pass -f to overwrite it"
env_dir="$(dirname "$env_file")"
[ -d "$env_dir" ] || die "no such directory: $env_dir"

vault_status="$(bw --nointeraction status | jq -r '.status')" || die "cannot query 'bw status'"
[ "$vault_status" = "unlocked" ] || die "vault is $vault_status, use 'bwu' first"

item="$(bw --nointeraction get item "$item_ref")" || die "cannot read item '$item_ref'"

# built in full before anything is written, so a value we cannot express aborts
# the whole export instead of leaving half a file behind
lines="$(printf '%s' "$item" | jq -r '
    (.fields // [])[]
    # type 1 is a hidden field
    | select(.type == 1 and .name != null and .value != null)
    | .name as $n | .value as $v
    | if ($n | test("^[A-Za-z_][A-Za-z0-9_]*$") | not) then
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
')"
[ -n "$lines" ] || die "item '$item_ref' has no hidden fields"

# mktemp gives us 0600, and the rename keeps a failed export from clobbering anything
tmp="$(mktemp "$env_dir/.bw-env-export.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
{
    printf '# written by bw-env-export from the bitwarden item %s\n' "${item_ref//$'\n'/ }"
    printf '%s\n' "$lines"
} >"$tmp"
mv "$tmp" "$env_file"
trap - EXIT

# names only, never the values
printf 'bw-env-export: wrote %s secrets to %s (mode 0600): %s\n' \
    "$(printf '%s\n' "$lines" | wc -l | tr -d ' ')" "$env_file" \
    "$(printf '%s' "$item" | jq -r '[(.fields // [])[] | select(.type == 1) | .name] | join(", ")')" >&2
