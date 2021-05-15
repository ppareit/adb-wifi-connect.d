#!/usr/bin/env bash

set -x
set -e
source ./config.sh

set +e
while true; do
  nmap_output="$(nmap "${ANDROID_HOSTS}" -p "T:${ANDROID_PORTS}" --max-retries 0 --host-timeout "${ANDROID_HOSTS_TIMEOUT}")"
  echo "nmap_output=${nmap_output}"
  while IFS= read -r line ; do
    if [[ "${line}" =~ ^Nmap\ scan\ report\ for.*\((.*)\)$ ]]; then
      current_host="${BASH_REMATCH[1]}"
    fi
    if [[ "${line}" =~ ^([[:digit:]]*)\/tcp.*open.*$ ]]; then
      current_port="${BASH_REMATCH[1]}"
      adb start-server
      adb connect "${current_host}:${current_port}"
    fi
  done <<< "${nmap_output}"
  sleep "${POLL_SLEEP_SECONDS}"
done
