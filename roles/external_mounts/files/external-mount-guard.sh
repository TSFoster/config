#!/bin/bash
# Restart only the containers that actually mount a given path, instead of
# the whole Docker daemon. Invoked once per external mount (see
# roles/external_mounts) as `external-mount-guard restart <path>`, by that
# mount's own generated systemd unit whenever its mount unit (re)mounts
# successfully.
#
# Scans running containers for a mount whose source is <path> (or a path
# under it) and `docker restart`s them, so each one gets a fresh bind mount
# pointing at the drive that's now attached — a live bind mount doesn't
# refresh on its own just because the backing device cycled out and back
# in. If none are running yet (e.g. the very first successful mount at
# boot, before Docker has brought containers up), this is a no-op — they'll
# start against the current mount on their own.
set -euo pipefail

action=${1:?usage: external-mount-guard restart <path>}
path=${2:?usage: external-mount-guard restart <path>}

if [ "$action" != restart ]; then
  echo "usage: $0 restart <path>" >&2
  exit 1
fi

uses_path() {
  local id=$1 src
  while IFS= read -r src; do
    case "$src" in
      "$path" | "$path"/*) return 0 ;;
    esac
  done < <(docker inspect --format '{{range .Mounts}}{{.Source}}{{"\n"}}{{end}}' "$id")
  return 1
}

for id in $(docker ps -q); do
  if uses_path "$id"; then
    docker restart "$id"
  fi
done
