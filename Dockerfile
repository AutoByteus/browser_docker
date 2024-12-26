
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99

# Install required packages
RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    xfce4 \
    xfce4-terminal \
    supervisor \
    wget \
    curl \
    dbus-x11 \
    # Add network troubleshooting tools
    iputils-ping \
    dnsutils \
    net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome browser
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create directory for supervisor config
RUN mkdir -p /var/log/supervisor

# Set up VNC password
RUN mkdir ~/.vnc
RUN x11vnc -storepasswd mysecretpassword ~/.vnc/passwd

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 5900 9222

CMD ["/usr/bin/supervisord"]
