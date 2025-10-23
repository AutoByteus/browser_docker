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

# DBus configuration
mkdir -p /var/run/dbus
chown messagebus:messagebus /var/run/dbus
chmod 755 /var/run/dbus

# Create supervisor socket directory
mkdir -p "$(dirname /var/run/supervisor.sock)"
chown vncuser:vncuser "$(dirname /var/run/supervisor.sock)"

# Start supervisord as root from its standard location
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
