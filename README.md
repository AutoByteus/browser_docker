# Docker Browser Test Environment

This repository contains a Docker setup for a browser environment with VNC access.

## Features
- Ubuntu 22.04 with XFCE4 desktop environment
- Chromium browser pre-installed and configured
- VNC server for remote desktop access (no password required)
- Screen lock/screensaver disabled for uninterrupted operation
- Multi-architecture support (AMD64 and ARM64)

## Publishing to Docker Hub

### Single Architecture Build (Legacy Method)

Follow these steps to publish a single-architecture version of this image to Docker Hub:

1. Build the image locally:
```bash
docker-compose build
```

2. Login to Docker Hub:
```bash
docker login
```
You'll be prompted for your Docker Hub username and password.

3. Tag the image with your Docker Hub username:
```bash
docker tag autobyteus-base autobyteus/chrome-vnc:latest
```

4. Push to Docker Hub:
```bash
docker push autobyteus/chrome-vnc:latest
```

### Multi-Architecture Build (Recommended)

To create an image that works on both x86 (Intel/AMD) and ARM (Apple Silicon M1/M2/M3) architectures:

1. Make sure Docker BuildX is installed and enabled:
```bash
docker buildx version
```

2. Use the provided script to build and push a multi-architecture image:
```bash
# Build for multiple architectures but don't push yet
./build-multi-arch.sh

# Build and push to Docker Hub (requires docker login first)
./build-multi-arch.sh --push

# Build with a specific tag
./build-multi-arch.sh --tag v1.0.0 --push

# Build with no cache
./build-multi-arch.sh --no-cache --push
```

This will create a manifest list on Docker Hub that allows users to pull one image that works across different CPU architectures.

### Updating the Image

When you make changes and want to update the published image:

1. For single architecture:
```bash
# Rebuild with no cache
docker-compose build --no-cache

# Remove old images if needed
docker rmi autobyteus-base:latest autobyteus/chrome-vnc:latest

# Tag and push again
docker tag autobyteus-base autobyteus/chrome-vnc:latest
docker push autobyteus/chrome-vnc:latest
```

2. For multi-architecture:
```bash
# Rebuild and push with no cache
./build-multi-arch.sh --no-cache --push
```

## Using the Image

Once published, users can pull the image on any supported platform:

```bash
docker pull autobyteus/chrome-vnc:latest
```

The correct architecture will be automatically selected based on the host system.

## VNC Access

The VNC server is configured without password authentication for convenience when running locally. No password is required when connecting with a VNC client. Screen locking and screensaver have been disabled to prevent session timeout issues.
