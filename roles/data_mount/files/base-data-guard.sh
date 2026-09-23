#!/bin/bash
# Stop/start only the containers that actually mount base_data, instead of
# the whole Docker daemon. Invoked by base-data-containers.service as
# `base-data-guard stop|start <base_data>`.
#
# stop: scan running containers for a mount whose source is base_data (or a
# path under it), record their IDs, then `docker stop` them. `docker stop`
# marks them user-stopped, so an `unless-stopped` restart policy won't race
# to bring them back up against a missing/reappearing mount.
#
# start: `docker start` whatever was recorded by the last stop. If nothing
# was ever recorded (e.g. the very first successful mount at boot), this is
# a no-op — Docker's own restart policy already brought those containers up.
set -euo pipefail

action=${1:?usage: base-data-guard start|stop <base_data>}
base_data=${2:?usage: base-data-guard start|stop <base_data>}
state_file=/run/base-data-guard.containers

uses_base_data() {
  local id=$1 src
  while IFS= read -r src; do
    case "$src" in
      "$base_data" | "$base_data"/*) return 0 ;;
    esac
  done < <(docker inspect --format '{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}' "$id")
  return 1
}

case "$action" in
  stop)
    : >"$state_file"
    for id in $(docker ps -q); do
      if uses_base_data "$id"; then
        echo "$id" >>"$state_file"
      fi
    done
    if [ -s "$state_file" ]; then
      xargs docker stop <"$state_file"
    fi
    ;;
  start)
    if [ -s "$state_file" ]; then
      xargs docker start <"$state_file"
    fi
    ;;
  *)
    echo "usage: $0 start|stop <base_data>" >&2
    exit 1
    ;;
esac
