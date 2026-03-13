#!/usr/bin/env bash
# Demo recording script for visualping
# Start screen recording (Cmd+Shift+5) BEFORE running this script.
# Each command runs sequentially with pauses between animations.

set -e

run() {
  echo
  local cmd="\$ $*"
  for ((i=0; i<${#cmd}; i++)); do
    printf '%s' "${cmd:$i:1}"
    sleep 0.02
  done
  echo
  "$@"
}

sleep 2

run visualping done --duration 3
sleep 1

run visualping attention --position center --size 25% --duration 3
sleep 1

run visualping attention --label "Deploy ready" --duration 3
sleep 1

run visualping confetti --fullscreen --duration 4

sleep 2
echo "=== Done! Stop screen recording now. ==="
