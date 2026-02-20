#!/bin/bash
set -eo pipefail

# Create required directories with root
mkdir -p /var/run/supervisor
chmod 755 /var/run/supervisor
chown vncuser:vncuser /var/run/supervisor

# Set runtime directory from environment
export XDG_RUNTIME_DIR=/run/user/1000
mkdir -p ${XDG_RUNTIME_DIR}
mkdir -p ${XDG_RUNTIME_DIR}/dconf
chown -R vncuser:vncuser ${XDG_RUNTIME_DIR}
chmod -R 700 ${XDG_RUNTIME_DIR}
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

# DBus configuration
mkdir -p /var/run/dbus
chown messagebus:messagebus /var/run/dbus
chmod 755 /var/run/dbus

# FIX: Clear potential stale PID file before starting supervisord/dbus
rm -f /run/dbus/pid

# Clear stale X display artifacts left by abrupt container shutdown.
DISPLAY_NUM="${DISPLAY:-:99}"
DISPLAY_NUM="${DISPLAY_NUM#:}"
rm -f "/tmp/.X${DISPLAY_NUM}-lock" "/tmp/.X11-unix/X${DISPLAY_NUM}"

# Create supervisor socket directory
mkdir -p "$(dirname /var/run/supervisor.sock)"
chown vncuser:vncuser "$(dirname /var/run/supervisor.sock)"

# Start supervisord as root from its standard location
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
