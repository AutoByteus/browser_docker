# Base image for all architectures
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99
ENV CHROME_FLAGS="--disable-dev-shm-usage --no-sandbox --disable-gpu --disable-software-rasterizer"

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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Chromium using PPA
RUN add-apt-repository -y ppa:xtradeb/apps && \
    apt-get update && \
    apt-get install -y chromium && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup supervisor
RUN mkdir -p /var/run && \
    mkdir -p /var/log/supervisor && \
    touch /var/run/supervisor.sock && \
    chmod 700 /var/run/supervisor.sock

# Create non-root user
RUN useradd -m -s /bin/bash vncuser && \
    echo "vncuser:vncuser" | chpasswd && \
    adduser vncuser sudo && \
    echo "vncuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Create .vnc directory and set password
RUN mkdir -p /home/vncuser/.vnc && \
    x11vnc -storepasswd mysecretpassword /home/vncuser/.vnc/passwd && \
    chown -R vncuser:vncuser /home/vncuser/.vnc && \
    chmod -R 755 /home/vncuser/.vnc

# Setup X11 and shared memory permissions
RUN mkdir -p /tmp/.X11-unix && \
    chmod 1777 /tmp/.X11-unix && \
    mkdir -p /dev/shm && \
    chmod 1777 /dev/shm && \
    chown -R vncuser:vncuser /tmp/.X11-unix

# Setup DBus directories and permissions
RUN mkdir -p /run/dbus && \
    chown messagebus:messagebus /run/dbus && \
    dbus-uuidgen > /etc/machine-id

# Setup Xauthority
RUN touch /home/vncuser/.Xauthority && \
    chown vncuser:vncuser /home/vncuser/.Xauthority && \
    chmod 600 /home/vncuser/.Xauthority

# Create log directory for x11vnc
RUN mkdir -p /var/log/supervisor && \
    chown -R vncuser:vncuser /var/log/supervisor

# Fix permissions
RUN chown -R vncuser:vncuser /home/vncuser && \
    chown vncuser:vncuser /var/run/supervisor.sock
    
# Create XDG_RUNTIME_DIR and set permissions
RUN mkdir -p /run/user/1000 && \
    chown -R vncuser:vncuser /run/user/1000 && \
    chmod -R 700 /run/user/1000

# Set XDG_RUNTIME_DIR environment variable
ENV XDG_RUNTIME_DIR=/run/user/1000

# Create workspace directory for VNC
RUN mkdir -p /home/vncuser/workspace && \
    chown -R vncuser:vncuser /home/vncuser/workspace

WORKDIR /home/vncuser/workspace

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY entrypoint.sh /entrypoint.sh

RUN dos2unix /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE 5900 9223

ENTRYPOINT ["/entrypoint.sh"]
