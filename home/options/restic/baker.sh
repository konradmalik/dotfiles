# shellcheck shell=bash
# baker: restic for a single repository, plus what the scheduled jobs need on
# top of it. Everything about the repository comes from the environment, set by
# the baker-<name> wrapper that default.nix generates for each repository:
#
#   RESTIC_REPOSITORY, RESTIC_PASSWORD_FILE   plus whatever the backend needs
#   BAKER_NAME                                repository name, for notifications
#   BAKER_INCLUDE_FILE, BAKER_EXCLUDE_FILE    one path or pattern per line
#   BAKER_KEEP                                forget flags, "--keep-daily 7 ..."
#   BAKER_MAX_AGE_DAYS                        watchdog threshold, unset disables it
#   BAKER_NTFY_TOKEN_FILE, BAKER_NTFY_TOPIC_FILE
set -uo pipefail

usage() {
    echo "usage: baker-$BAKER_NAME <command> [args]"
    echo
    echo "commands:"
    echo "  backup          back up the configured paths"
    echo "  forget [args]   apply the retention policy, pass --prune to also free the space"
    echo "  check [args]    verify the repository"
    echo "  watchdog        fail when this host's newest snapshot is too old"
    echo "  run <command>   (used in systemd/launchd units) run one of the above as a scheduled job: log it, notify on failure"
    echo
    echo "anything else is passed to restic as is, e.g. snapshots, init or unlock."
}

# --retry-lock makes every command wait for a lock held by another host sharing
# the repository instead of failing immediately. forget --prune takes an
# exclusive lock and would otherwise fail whenever any other host is backing up.
restic() {
    command restic --retry-lock 1h "$@"
}

# An interrupted run (a laptop going to sleep mid-backup) leaves its lock in the
# repository. restic only removes locks that are provably stale: from this host
# with a dead pid, or not refreshed for 30 minutes. So this can never race a
# live run on any host.
unlock_stale() {
    echo "--> removing stale locks"
    restic unlock
}

backup() {
    echo "--> backing up"
    unlock_stale
    restic backup \
        --files-from "$BAKER_INCLUDE_FILE" \
        --exclude-file "$BAKER_EXCLUDE_FILE" \
        --exclude-caches \
        --exclude-if-present .nobackup
}

# host,paths is restic's default, spelled out because it matters: with one
# repository shared by several machines, grouping by paths alone would pool
# every host into one group, so one machine's snapshots could satisfy the policy
# and another's be forgotten whole.
forget() {
    local keep
    read -ra keep <<<"$BAKER_KEEP"
    echo "--> applying the retention policy"
    unlock_stale
    restic forget --group-by host,paths "${keep[@]}" "$@"
}

check() {
    echo "--> checking the repository"
    unlock_stale
    restic check "$@"
}

watchdog() {
    local max_days="${BAKER_MAX_AGE_DAYS:?the watchdog is disabled for this repository}"
    local host snapshots latest age pretty
    host="$(uname -n)"

    if ! snapshots="$(restic snapshots --latest 1 --host "$host" --json)"; then
        echo "could not read the repository"
        return 10
    fi

    latest="$(jq -r '.[0].time // empty' <<<"$snapshots")"
    if [[ -z $latest ]]; then
        echo "the repository holds no snapshot at all for host $host"
        return 90
    fi

    age=$(($(date +%s) - $(date -d "$latest" +%s)))
    pretty="$((age / 86400))d $((age % 86400 / 3600))h"
    echo "newest snapshot for $host is $pretty old, taken at $latest"

    if ((age > max_days * 86400)); then
        echo "that is more than the allowed ${max_days}d"
        return 90
    fi
}

# restic's documented exit codes, because a bare "exit 11" gives no clue that
# the repository was simply locked by another host
reason() {
    case "$1" in
    1) echo "command failed" ;;
    2) echo "go runtime error" ;;
    3) echo "some source data could not be read" ;;
    10) echo "repository does not exist" ;;
    11) echo "failed to lock the repository" ;;
    12) echo "wrong password" ;;
    130) echo "interrupted" ;;
    # baker's own, not restic's
    90) echo "backups have stopped" ;;
    *) echo "unknown error" ;;
    esac
}

notify() {
    ntfy-send \
        --token-file "$BAKER_NTFY_TOKEN_FILE" \
        --topic-file "$BAKER_NTFY_TOPIC_FILE" \
        --priority "$1" \
        --tags "$2" \
        --title "baker: $BAKER_NAME $3"
}

# Only failures are notified: backups run every hour on every machine, so
# success pings would only bury the ones that mean something.
run() {
    local job="${1:?usage: run <command>}"

    # A local repository sits on a disk that is not always attached, and there
    # is nothing to report while it is away. The watchdog still runs, so a disk
    # that stays away for too long does get noticed.
    if [[ $job != watchdog && $RESTIC_REPOSITORY == /* && ! -e $RESTIC_REPOSITORY/config ]]; then
        echo "$RESTIC_REPOSITORY is not available, skipping"
        return 0
    fi

    local log start code elapsed head prio tag
    log="$(mktemp)"
    # shellcheck disable=SC2064 # expand now, the variable is local
    trap "rm -f '$log'" EXIT

    echo "=== $* started $(date)"
    start="$SECONDS"
    if main "$@" 2>&1 | tee "$log"; then code=0; else code="${PIPESTATUS[0]}"; fi
    elapsed=$((SECONDS - start))
    elapsed="$(printf '%dh%02dm%02ds' $((elapsed / 3600)) $((elapsed % 3600 / 60)) $((elapsed % 60)))"
    echo "=== $* finished with exit code $code $(date)"

    if ((code != 0)); then
        # a backup that could not read some files still wrote a snapshot, so
        # that is a warning rather than a failure
        if ((code == 3)); then
            head="warnings in $elapsed: $(reason "$code")"
            prio=default
            tag=warning
        else
            head="failed in $elapsed: $(reason "$code") (exit $code)"
            prio=high
            tag=x
        fi

        # every restic command ends with its own summary, so the body is simply
        # the tail of the log, minus progress and blank line noise
        printf '%s\n\n%s\n' "$head" "$(grep -vE '^(\[|$)' "$log" | tail -n 15)" |
            notify "$prio" "$tag" "$job"
    fi

    return "$code"
}

main() {
    local cmd="${1-}"
    shift || true
    case "$cmd" in
    backup | forget | check | watchdog | run) "$cmd" "$@" ;;
    "" | help | -h | --help) usage ;;
    *) restic "$cmd" "$@" ;;
    esac
}

main "$@"
