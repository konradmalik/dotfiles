{ name, cmd, ntfyPath, writeShellScript, curl, coreutils, inetutils }:
writeShellScript "${name}.sh" ''
  echo "${name}"
  ${coreutils}/bin/date
  ${cmd}
  code=$?
  if [[ "$code" == 0 ]]; then
    ${curl}/bin/curl --silent --show-error --max-time 10 --retry 5 \
      --header "Title: Baker status" \
      --header prio:min \
      --data "$(${inetutils}/bin/hostname): ${name} succeeded" \
      ntfy.sh/$(<${ntfyPath}) > /dev/null
  else
    ${curl}/bin/curl --silent --show-error --max-time 10 --retry 5 \
      --header "Title: Baker status" \
      --header tags:warning \
      --header prio:high \
      --data "$(${inetutils}/bin/hostname): ${name} failed" \
      ntfy.sh/$(<${ntfyPath}) > /dev/null
  fi
  echo
''
