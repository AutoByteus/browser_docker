
# Headless Browser Environment with VNC Access

This project provides a Docker-based headless browser environment with VNC access, allowing you to interact with a full Chrome browser instance remotely.

## Prerequisites

- Docker and Docker Compose installed on your system
- A VNC viewer application installed on your client machine

## Getting Started

1. Clone this repository to your local machine
2. Navigate to the project directory
3. Build and start the container:

```bash
docker-compose up -d
```

The container will start and expose port 5900 for VNC access.

## Connecting to the Environment

The VNC password is: `mysecretpassword`

### TigerVNC (Recommended)

TigerVNC is a high-performance, robust, and feature-rich VNC client available for all major platforms.

#### Installation

**Windows:**
1. Download TigerVNC from the [official website](https://tigervnc.org/downloads/)
2. Run the installer
3. Launch TigerVNC Viewer
4. Enter `localhost:5900` in the VNC Server field
5. Click Connect and enter the password

**macOS:**
```bash
brew install tiger-vnc
```
Then launch `vncviewer` and connect to `localhost:5900`

**Linux:**

Ubuntu/Debian:
```bash
sudo apt-get install tigervnc-viewer
```

Fedora:
```bash
sudo dnf install tigervnc
```

Arch Linux:
```bash
sudo pacman -S tigervnc
```

To connect using TigerVNC:
```bash
vncviewer localhost:5900
```

TigerVNC Features:
- Better performance than traditional VNC clients
- Support for SSH tunneling
- Advanced encryption options
- Various compression levels
- Custom keyboard mapping
- Multiple monitor support

### Alternative VNC Clients

#### Windows

- [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)
- [TightVNC](https://www.tightvnc.com/download.php)

#### macOS

1. Open Finder
2. Press Cmd+K or select Go > Connect to Server
3. Enter: `vnc://localhost:5900`
4. Enter the password when prompted

Alternatively, you can use [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)

#### Linux

Most Linux distributions come with built-in VNC viewers. You can use:

- Remmina (GNOME)
```bash
remmina -c vnc://localhost:5900
```

- Vinagre
```bash
vinagre localhost:5900
```

## Environment Details

- Ubuntu 22.04 base system
- XFCE4 desktop environment
- Google Chrome browser installed
- Screen resolution: 1280x1024

## Troubleshooting

### Connection Refused

If you cannot connect to the VNC server:

1. Verify the container is running:
```bash
docker ps
```

2. Check the container logs:
```bash
docker-compose logs
```

3. Ensure port 5900 is not in use by another application:
```bash
netstat -an | grep 5900
```

### Black Screen

If you see a black screen after connecting:

1. Restart the container:
```bash
docker-compose restart
```

2. Check the supervisor logs:
```bash
docker-compose exec headless-browser cat /var/log/supervisor/supervisord.log
```

### Poor Performance

1. Reduce the color depth in your VNC viewer settings
2. Consider using a compressed connection option if available in your VNC viewer
3. For TigerVNC, try the following options:
   - Use the `-quality` parameter to adjust image quality (0-9)
   - Enable compression with `-compress` parameter
   - Use `-encoding` parameter to specify different encodings (tight, zrle, hextile)
4. Ensure you have a stable network connection

## Security Considerations

- The default VNC password is set to `mysecretpassword`. It's recommended to change this in production environments.
- VNC traffic is not encrypted by default. For production use, consider setting up an SSH tunnel or VPN.
- When using TigerVNC, you can set up SSH tunneling for secure connections:
```bash
ssh -L 5900:localhost:5900 user@remote-host
```
- The container runs with bridge networking mode for isolation.

## Network Configuration

- The container uses Google DNS servers (8.8.8.8 and 8.8.4.4)
- Bridge network mode is enabled for proper network isolation
- Port 5900 is exposed for VNC access

## License

This project is open-source and available under the MIT license.
