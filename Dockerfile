# Base image for all architectures
FROM ubuntu:22.04

ARG USER_UID=1000
ARG USER_GID=1000
ENV USER_UID=${USER_UID}
ENV USER_GID=${USER_GID}

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99
ENV XDG_RUNTIME_DIR=/run/user/${USER_UID}

# Install required packages
RUN apt-get update && apt-get install -y \
    dbus-x11 \
    dnsutils \
    iputils-ping \
    net-tools \
    sudo \
    supervisor \
    vim \
    wget \
    curl \
    x11vnc \
    xfce4 \
    xfce4-terminal \
    xvfb \
    libx11-dev \
    libxext-dev \
    libxtst-dev \
    dbus \
    dos2unix \
    python3 \
    python3-pip \
    socat \
    git \
    xclip \
    software-properties-common \
    xdotool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Chromium using PPA
RUN add-apt-repository -y ppa:xtradeb/apps && \
    apt-get update && \
    apt-get install -y chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install websockify for noVNC
RUN pip3 install websockify

# Create non-root user with explicit UID/GID and add to sudo group
RUN groupadd -g ${USER_GID} vncuser && \
    useradd -u ${USER_UID} -g ${USER_GID} -m -s /bin/bash vncuser && \
    usermod -aG sudo vncuser && \
    echo "vncuser:vncuser" | chpasswd && \
    echo "vncuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vncuser && \
    chmod 0440 /etc/sudoers.d/vncuser

# Setup supervisor with correct permissions
RUN mkdir -p /var/log/supervisor && \
    chown -R vncuser:vncuser /var/log/supervisor && \
    chmod 755 /var/log/supervisor

# Create .vnc directory (no password file created)
RUN mkdir -p /home/vncuser/.vnc && \
    chown -R ${USER_UID}:${USER_GID} /home/vncuser/.vnc && \
    chmod 700 /home/vncuser/.vnc

# Setup X11 and shared memory permissions
RUN mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    mkdir -p /dev/shm && \
    chmod 1777 /dev/shm && \
    chown -R ${USER_UID}:${USER_GID} /tmp/.X11-unix

# Setup DBus directories and permissions
RUN mkdir -p /run/dbus && \
    chown messagebus:messagebus /run/dbus && \
    dbus-uuidgen > /etc/machine-id

# Setup Xauthority with secure permissions
RUN touch /home/vncuser/.Xauthority && \
    chown ${USER_UID}:${USER_GID} /home/vncuser/.Xauthority && \
    chmod 600 /home/vncuser/.Xauthority

# Create runtime directory with dynamic UID
RUN mkdir -p ${XDG_RUNTIME_DIR} && \
    chown -R ${USER_UID}:${USER_GID} ${XDG_RUNTIME_DIR} && \
    chmod 700 ${XDG_RUNTIME_DIR}

# Create workspace directory
RUN mkdir -p /home/vncuser/workspace && \
    chown -R ${USER_UID}:${USER_GID} /home/vncuser/workspace

WORKDIR /home/vncuser/workspace

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh
COPY disable-screensaver.sh /home/vncuser/disable-screensaver.sh
COPY keep-display-alive.sh /home/vncuser/keep-display-alive.sh

RUN dos2unix /entrypoint.sh /home/vncuser/disable-screensaver.sh /home/vncuser/keep-display-alive.sh && \
    chmod +x /entrypoint.sh /home/vncuser/disable-screensaver.sh /home/vncuser/keep-display-alive.sh && \
    chown vncuser:vncuser /entrypoint.sh /home/vncuser/disable-screensaver.sh /home/vncuser/keep-display-alive.sh /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5900 6080 9223

ENTRYPOINT ["/entrypoint.sh"]
