# restic exclude patterns: a pattern without a leading slash matches at any
# depth, "*" stays within one path component and "**" crosses any number of
# them. A directory is skipped as a whole, restic does not descend into it.
{ home, projects }:
[
  "*.o"
  "*.pyc"
  "*.log"
  "*-shm"
  "*-wal"
  "*.sqlite-journal"
  ".DS_Store"
  # syncthing's trashcan versioning, restic keeps its own history
  ".stversions"

  "__pycache__"
  "node_modules"
  ".direnv"
  ".mypy_cache"
  ".pytest_cache"
  ".ruff_cache"
  "${projects}/**/bin"
  "${projects}/**/obj"

  "${home}/.cache"
  "${home}/.local/share"
  "${home}/.local/state"
  "${home}/Downloads"

  "${home}/.azcopy"
  "${home}/.cargo"
  "${home}/.clangd"
  "${home}/.dotnet"
  "${home}/.go"
  "${home}/.gradle"
  "${home}/.m2"
  "${home}/.npm"
  "${home}/.nuget"
  "${home}/.opam"
  "${home}/.pnpm"
  "${home}/.terraform"
  "${home}/go"

  "${home}/.config/Slack"
  "${home}/.config/syncthing/index-v2"

  "${home}/.config/**/Cache"
  "${home}/.config/**/CachedData"
  "${home}/.config/**/Code Cache"
  "${home}/.config/**/Crashpad"
  "${home}/.config/**/DawnCache"
  "${home}/.config/**/GPUCache"
  "${home}/.config/**/ShaderCache"
  "${home}/.config/**/Service Worker/CacheStorage"

  # browser profiles
  "${home}/.config/mozilla"
  "${home}/.config/zen"

  # photos rebuilds these from the originals and its database
  "${home}/Pictures/*.photoslibrary/database/search"
  "${home}/Pictures/*.photoslibrary/resources/caches"
  "${home}/Pictures/*.photoslibrary/resources/derivatives"

  # authoritative copy lives on the imap server, unlike Mail/
  "${home}/.thunderbird/*/ImapMail"
  "${home}/.thunderbird/*/crashes"
  "${home}/.thunderbird/*/datareporting"
  "${home}/.thunderbird/*/minidumps"
  "${home}/.thunderbird/*/saved-telemetry-pings"
  "${home}/.thunderbird/*/global-messages-db.sqlite"
]
