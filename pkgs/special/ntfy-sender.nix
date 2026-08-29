{
  writeShellScript,
  curl,
  inetutils,
  config,
}:
let
  ntfyTokenFile = config.sops.secrets."ntfy/token".path;
  ntfyTopicFile = config.sops.secrets."ntfy/topic".path;
in
# https://docs.ntfy.sh/publish/
writeShellScript "ntfy-send" ''
  set -uo pipefail

  priority="default"
  tags=""
  title=""

  usage() {
    echo "usage: ntfy-send [options] [message]"
    echo
    echo "options:"
    echo "  -p, --priority  max|high|default|low|min (default: default)"
    echo "  -t, --tags      comma separated emoji shortcodes, shown before the title"
    echo "  -T, --title     notification title, always prefixed with the hostname"
    echo
    echo "the message is read from stdin when no message argument is given."
  }

  while [[ $# -gt 0 ]]; do
    case "$1" in
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

  # every machine publishes to the same topic, so the notification has to say
  # which one it came from. darwin hostnames carry a domain, strip it.
  host="$(${inetutils}/bin/hostname)"
  host="''${host%%.*}"

  args=(
    --header "Authorization: Bearer $(<${ntfyTokenFile})"
    --header "Title: [$host]''${title:+ $title}"
    --header "Priority: $priority"
  )
  # an empty Tags header is not the same as no Tags header, so only set it when
  # there is something to set
  [[ -n "$tags" ]] && args+=(--header "Tags: $tags")

  # --data-binary @- keeps newlines intact and stops curl from reading a message
  # that happens to start with @ as a file name
  { if (($# > 0)); then printf '%s' "$*"; else cat; fi; } |
    ${curl}/bin/curl --silent --show-error --fail --max-time 10 --retry 5 \
      "''${args[@]}" \
      --data-binary @- \
      "https://ntfy.sh/$(<${ntfyTopicFile})" > /dev/null
''
