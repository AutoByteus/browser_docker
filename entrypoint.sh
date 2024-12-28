#!/bin/bash
set -ex  # Added -x for debugging

# Enhanced debugging function
debug_info() {
    echo "=== Debugging Info ==="
    echo "D-Bus Directory Contents:"
    ls -la /var/run/dbus/
    echo "Process List:"
    ps aux
    echo "System Bus Socket:"
    ls -la /var/run/dbus/system_bus_socket 2>/dev/null || echo "Socket not found"
    echo "===================="
}

# Create D-Bus directory if it doesn't exist
mkdir -p /var/run/dbus
chown messagebus:messagebus /var/run/dbus
chmod 755 /var/run/dbus

# Cleanup any existing socket
rm -f /var/run/dbus/system_bus_socket
rm -f /var/run/dbus/pid

debug_info

# Wait for socket creation after supervisord starts D-Bus
for i in {1..10}; do
    if [ -e /var/run/dbus/system_bus_socket ]; then
        echo "D-Bus socket found"
        chmod 666 /var/run/dbus/system_bus_socket
        break
    fi
    echo "Waiting for D-Bus socket... attempt $i"
    sleep 1
done

debug_info

# Start supervisord
exec /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
