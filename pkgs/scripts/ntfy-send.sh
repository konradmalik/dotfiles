#!/usr/bin/env bash
# https://docs.ntfy.sh/publish/
set -uo pipefail

priority="default"
tags=""
title=""
token_file=""
topic_file=""

usage() {
    echo "usage: ntfy-send --token-file FILE --topic-file FILE [options] [message]"
    echo
    echo "options:"
    echo "  --token-file    file holding the ntfy access token"
    echo "  --topic-file    file holding the ntfy topic"
    echo "  -p, --priority  max|high|default|low|min (default: default)"
    echo "  -t, --tags      comma separated emoji shortcodes, shown before the title"
    echo "  -T, --title     notification title, always prefixed with the hostname"
    echo
    echo "the message is read from stdin when no message argument is given."
}

while [[ $# -gt 0 ]]; do
    case "$1" in
    --token-file)
        token_file="$2"
        shift 2
        ;;
    --topic-file)
        topic_file="$2"
        shift 2
        ;;
    -p | --priority)
        priority="$2"
        shift 2
        ;;
    -t | --tags)
        tags="$2"
        shift 2
        ;;
    -T | --title)
        title="$2"
        shift 2
        ;;
    -h | --help)
        usage
        exit 0
        ;;
    --)
        shift
        break
        ;;
    *)
        break
        ;;
    esac
done

if [[ -z "$token_file" || -z "$topic_file" ]]; then
    usage >&2
    exit 1
fi

# every machine publishes to the same topic, so the notification has to say
# which one it came from. darwin hostnames carry a domain, strip it.
host="$(hostname)"
host="${host%%.*}"

args=(
    --header "Authorization: Bearer $(<"$token_file")"
    --header "Title: [$host]${title:+ $title}"
    --header "Priority: $priority"
)
# an empty Tags header is not the same as no Tags header, so only set it when
# there is something to set
[[ -n "$tags" ]] && args+=(--header "Tags: $tags")

# --data-binary @- keeps newlines intact and stops curl from reading a message
# that happens to start with @ as a file name
{ if (($# > 0)); then printf '%s' "$*"; else cat; fi; } |
    curl --silent --show-error --fail --max-time 10 --retry 5 \
        "${args[@]}" \
        --data-binary @- \
        "https://ntfy.sh/$(<"$topic_file")" >/dev/null
