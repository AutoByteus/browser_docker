
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99
ENV CHROME_FLAGS="--disable-dev-shm-usage"

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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome browser
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5900

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
