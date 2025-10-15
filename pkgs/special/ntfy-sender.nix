{
  writeShellScript,
  curl,
  inetutils,
  config,
  priority ? "default",
  tags ? "",
  title,
  text,
}:
let
  ntfyTokenFile = config.sops.secrets."ntfy/token".path;
  ntfyTopicFile = config.sops.secrets."ntfy/topic".path;
in
# https://docs.ntfy.sh/publish/
writeShellScript "ntfy-sender.sh" ''
  ${curl}/bin/curl --silent --show-error --max-time 10 --retry 5 \
    --header "Authorization: Bearer $(<${ntfyTokenFile})" \
    --header "Title: [$(${inetutils}/bin/hostname)] ${title}" \
    --header prio:${priority} \
    --header tags:${tags} \
    --data "${text}" \
    https://ntfy.sh/$(<${ntfyTopicFile}) > /dev/null
''
