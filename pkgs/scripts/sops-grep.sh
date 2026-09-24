#!/usr/bin/env bash
# sops-grep -- search decrypted SOPS files without ever writing plaintext to disk.
#
# Plaintext never touches disk, but it does reach your scrollback, and the
# pattern reaches your shell history.

set -euo pipefail

usage() {
    cat >&2 <<'EOF'
sops-grep -- search decrypted SOPS files without ever writing plaintext to disk.

Usage:
  sops-grep <pattern> [path ...] [-- <rg flags>]
  sops-grep -e <pattern> ...        use -e when the pattern starts with "-"

Searches *.yaml, *.yml, *.json and *.env under each path (default: .). Only
files that sops itself reports as encrypted are searched, so nothing here
depends on the ciphertext format. Files that are encrypted but undecryptable
with your keys are listed on stderr rather than skipped silently -- with
per-env age keys, a silent skip is indistinguishable from "no match".

<pattern> is a ripgrep regex (Rust syntax), not a literal string. Pass "-- -F"
to match literally, which is what you want for most secret values: base64
blobs, connection strings and generated passwords are full of regex
metacharacters ("+", "/", "?", "."), so "a+b/c=d" as a regex will silently
fail to match the literal value a+b/c=d.

Exit status follows grep: 0 if something matched, 1 if nothing did.

Examples:
  sops-grep POSTGRES_PASSWORD
  sops-grep 'pgexxon.*storage' k8s/secrets/exxon-prod-k8s
  sops-grep clientsecret -- -i
  sops-grep 'a+b/c=d' -- -F
  sops-grep -e '-----BEGIN' -- -F

Environment:
  SOPS_GREP_JOBS    files decrypted in parallel (default 8, 1 sorts output)
EOF
    exit "${1:-2}"
}

pattern=""
paths=()
rg_flags=()
while [ $# -gt 0 ]; do
    case "$1" in
    --)
        shift
        rg_flags+=("$@")
        break
        ;;
    -e | --pattern)
        shift
        [ $# -gt 0 ] || usage
        pattern="$1"
        ;;
    -h | --help) usage 0 ;;
    -*) rg_flags+=("$1") ;;
    *) if [ -z "$pattern" ]; then pattern="$1"; else paths+=("$1"); fi ;;
    esac
    shift
done
[ -n "$pattern" ] || usage
[ ${#paths[@]} -gt 0 ] || paths=(.)

jobs_max="${SOPS_GREP_JOBS:-8}"
if [ -t 1 ]; then color=always; else color=never; fi

# reject a bad pattern or rg flag once here, instead of once per decrypted file
rg_status=0
printf '' | rg --color=never ${rg_flags[@]+"${rg_flags[@]}"} -- "$pattern" || rg_status=$?
[ "$rg_status" -le 1 ] || exit 2

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT
undecryptable="$tmpdir/undecryptable"
: >"$undecryptable"

search_file() {
    local file="$1" plaintext hits prefix out="" line

    case "$(sops filestatus "$file" 2>/dev/null)" in
    *'"encrypted":true'*) ;;
    *) return 0 ;; # plaintext, or not a sops file at all
    esac

    if ! plaintext="$(sops decrypt "$file" 2>/dev/null)"; then
        printf '%s\n' "$file" >>"$undecryptable"
        return 0
    fi

    # rg reads stdin here, so it has no filename of its own to print
    hits="$(printf '%s\n' "$plaintext" |
        rg --line-number --color="$color" ${rg_flags[@]+"${rg_flags[@]}"} -- "$pattern")" || return 0

    prefix="$file:"
    [ "$color" = never ] || prefix=$'\033[35m'"$file"$'\033[0m:'
    # one write per file, so parallel workers cannot interleave mid-result
    while IFS= read -r line; do out+="$prefix$line"$'\n'; done <<<"$hits"
    printf '%s' "$out"
    touch "$tmpdir/matched"
}

for path in "${paths[@]}"; do
    [ -e "$path" ] || {
        printf 'sops-grep: %s: no such file or directory\n' "$path" >&2
        exit 2
    }
done

mapfile -d '' -t files < <(
    find "${paths[@]}" -type f \
        \( -name '*.yaml' -o -name '*.yml' -o -name '*.json' -o -name '*.env' \) \
        -print0 | sort -z
)
if [ ${#files[@]} -eq 0 ]; then
    printf 'sops-grep: no yaml/yml/json/env files under: %s\n' "${paths[*]}" >&2
    exit 1
fi

for file in "${files[@]}"; do
    while [ "$(jobs -pr | wc -l)" -ge "$jobs_max" ]; do wait -n || true; done
    search_file "$file" &
done
wait || true

if [ -s "$undecryptable" ]; then
    printf '\nencrypted, but no usable key (check .sops.yaml key_groups):\n' >&2
    sort -u "$undecryptable" | while IFS= read -r file; do printf '  %s\n' "$file"; done >&2
fi

[ -e "$tmpdir/matched" ]
