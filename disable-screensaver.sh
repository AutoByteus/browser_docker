#!/bin/bash

# Disable XFCE screensaver and screen locking
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/

# Create or update the power manager settings to disable screen locking
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-power-manager" version="1.0">
  <property name="xfce4-power-manager" type="empty">
    <property name="dpms-enabled" type="bool" value="false"/>
    <property name="blank-on-ac" type="int" value="0"/>
    <property name="lock-screen-suspend-hibernate" type="bool" value="false"/>
    <property name="logind-handle-lid-switch" type="bool" value="false"/>
    <property name="show-tray-icon" type="bool" value="false"/>
    <property name="general-notification" type="bool" value="false"/>
    <property name="presentation-mode" type="bool" value="true"/>
    <property name="inactivity-sleep-mode-on-ac" type="uint" value="1"/>
    <property name="inactivity-on-ac" type="uint" value="0"/>
    <property name="critical-power-action" type="uint" value="0"/>
    <property name="blank-on-battery" type="int" value="0"/>
    <property name="dpms-on-ac-off" type="uint" value="0"/>
    <property name="dpms-on-ac-sleep" type="uint" value="0"/>
    <property name="dpms-on-battery-off" type="uint" value="0"/>
    <property name="dpms-on-battery-sleep" type="uint" value="0"/>
  </property>
</channel>
EOF

# Create or update the screensaver settings to disable it
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-screensaver.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-screensaver" version="1.0">
  <property name="saver" type="empty">
    <property name="mode" type="int" value="0"/>
    <property name="enabled" type="bool" value="false"/>
  </property>
  <property name="lock" type="empty">
    <property name="enabled" type="bool" value="false"/>
  </property>
</channel>
EOF

# Disable XFCE session screensaver
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<channel name="xfce4-session" version="1.0">
  <property name="general" type="empty">
    <property name="FailsafeSessionName" type="string" value="Failsafe"/>
    <property name="SessionName" type="string" value="Default"/>
    <property name="SaveOnExit" type="bool" value="true"/>
  </property>
  <property name="sessions" type="empty">
    <property name="Failsafe" type="empty">
      <property name="IsFailsafe" type="bool" value="true"/>
      <property name="Count" type="int" value="5"/>
      <property name="Client0_Command" type="array">
        <value type="string" value="xfwm4"/>
      </property>
      <property name="Client1_Command" type="array">
        <value type="string" value="xfsettingsd"/>
      </property>
      <property name="Client2_Command" type="array">
        <value type="string" value="xfce4-panel"/>
      </property>
      <property name="Client3_Command" type="array">
        <value type="string" value="Thunar"/>
        <value type="string" value="--daemon"/>
      </property>
      <property name="Client4_Command" type="array">
        <value type="string" value="xfdesktop"/>
      </property>
    </property>
  </property>
  <property name="splash" type="empty">
    <property name="Engine" type="string" value=""/>
  </property>
  <property name="shutdown" type="empty">
    <property name="LockScreen" type="bool" value="false"/>
  </property>
  <property name="startup" type="empty">
    <property name="screensaver" type="empty">
      <property name="enabled" type="bool" value="false"/>
    </property>
  </property>
</channel>
EOF

# Create or update display settings to disable DPMS
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/displays.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>

<channel name="displays" version="1.0">
  <property name="Default" type="empty">
    <property name="DISPLAY99" type="string" value="DISPLAY99">
      <property name="DPMS" type="bool" value="false"/>
    </property>
  </property>
</channel>
EOF

# Disable Xfce display power management
cat > ~/.config/xfce4/autostart/dpms-disable.desktop << EOF
[Desktop Entry]
Encoding=UTF-8
Version=0.9.4
Type=Application
Name=Disable DPMS
Comment=Disable screen blanking
Exec=xset -dpms s off s noblank s 0 0 s noexpose
OnlyShowIn=XFCE;
StartupNotify=false
Terminal=false
Hidden=false
EOF

# Disable light locker if it's installed
if command -v light-locker-command &> /dev/null; then
    light-locker-command -k
    pkill light-locker
    
    # Prevent light-locker from starting
    mkdir -p ~/.config/autostart/
    if [ -f /etc/xdg/autostart/light-locker.desktop ]; then
        cp /etc/xdg/autostart/light-locker.desktop ~/.config/autostart/
        echo "Hidden=true" >> ~/.config/autostart/light-locker.desktop
    fi
fi

# Make sure xscreensaver is not running if installed
if command -v xscreensaver &> /dev/null; then
    pkill xscreensaver
    
    # Create xscreensaver config to disable it
    mkdir -p ~/.xscreensaver
    echo "mode:		off" > ~/.xscreensaver
    
    # Prevent xscreensaver from starting
    mkdir -p ~/.config/autostart/
    if [ -f /etc/xdg/autostart/xscreensaver.desktop ]; then
        cp /etc/xdg/autostart/xscreensaver.desktop ~/.config/autostart/
        echo "Hidden=true" >> ~/.config/autostart/xscreensaver.desktop
    fi
fi

# Additional settings to prevent screen blanking
xset s off
xset -dpms
xset s noblank
xset s 0 0
xset s noexpose

# Disable gnome-screensaver if present
if command -v gnome-screensaver-command &> /dev/null; then
    gnome-screensaver-command -d
    pkill gnome-screensaver
fi

# Apply settings to the X server
# These commands will both be executed and be added to Xfce autostart for persistence
(
  sleep 2
  xset s off
  xset -dpms
  xset s noblank
  xset s 0 0
  xset s noexpose
) &

echo "Screen locking and screensaver have been disabled"
