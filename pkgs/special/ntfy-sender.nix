{
  writeShellScript,
  curl,
  inetutils,
  ntfyTokenFile,
  ntfyHost ? "https://ntfy.sh",
  ntfyTopicFile,
  priority ? "default",
  tags ? "",
  title,
  text,
}:
# https://docs.ntfy.sh/publish/
writeShellScript "ntfy-sender.sh" ''
  ${curl}/bin/curl --silent --show-error --max-time 10 --retry 5 \
    --header "Authorization: Bearer $(<${ntfyTokenFile})" \
    --header "Title: [$(${inetutils}/bin/hostname)] ${title}" \
    --header prio:${priority} \
    --header tags:${tags} \
    --data "${text}" \
    ${ntfyHost}/$(<${ntfyTopicFile}) > /dev/null
''
