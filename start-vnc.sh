#!/bin/bash
set -euo pipefail

display="${DISPLAY:-:99}"
display_num="${display#:}"
lock_file="/tmp/.X${display_num}-lock"
socket_file="/tmp/.X11-unix/X${display_num}"

mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Remove stale X lock/socket if they do not belong to an active X server process.
if [ -f "$lock_file" ]; then
  lock_pid="$(tr -cd '0-9' < "$lock_file" || true)"
  if [ -n "$lock_pid" ] && ps -p "$lock_pid" -o comm= 2>/dev/null | grep -Eq 'Xvnc|Xtigervnc|Xorg|Xvfb'; then
    echo "Display $display appears to be used by live PID $lock_pid; refusing to start duplicate X server." >&2
    exit 1
  fi
  echo "Removing stale X lock/socket for display $display."
  rm -f "$lock_file" "$socket_file"
fi

resolution="${SCREEN_RESOLUTION:-1920x1080x24}"
geometry="$resolution"
depth="24"
if [[ "$resolution" =~ ^([0-9]+x[0-9]+)x([0-9]+)$ ]]; then
  geometry="${BASH_REMATCH[1]}"
  depth="${BASH_REMATCH[2]}"
fi

exec /usr/bin/Xvnc "$display" \
  -geometry "$geometry" \
  -depth "$depth" \
  -rfbport 5900 \
  -SecurityTypes=None \
  -localhost no \
  -AlwaysShared
