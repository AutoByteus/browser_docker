# Docker Browser Test Environment

This repository contains a Docker setup for a browser environment with VNC access.

## Features
- Ubuntu 22.04 with XFCE4 desktop environment
- Chromium browser pre-installed and configured
- VNC server for remote desktop access (no password required)
- Screen lock/screensaver disabled for uninterrupted operation
- Multi-architecture support (AMD64 and ARM64)

## Building and Publishing to Docker Hub

This project uses Docker BuildX to create images. The script is optimized for both local development and publishing.

1.  **Set the Version**: Before building, update the `VERSION` file in this directory with the desired semantic version (e.g., `1.1.0`). This file is the single source of truth for versioning.

2.  **Ensure Docker BuildX is ready**:
    ```bash
    docker buildx version
    ```

3.  **Run the Build Script**: The script will automatically read the `VERSION` file and tag the image with both the specific version (e.g., `autobyteus/chrome-vnc:1.1.0`) and `latest`.

    **For Local Development (Default):**
    Running the script without any flags will build the image for your machine's architecture and load it directly into your local Docker daemon. The image will then be available in `docker images`.
    ```bash
    # Build for your local architecture and load into Docker
    ./build-multi-arch.sh
    ```

    **For Publishing:**
    To build the multi-architecture image and push it to Docker Hub, use the `--push` flag. This requires you to be logged in via `docker login` first.
    ```bash
    # Build for all architectures and push to Docker Hub
    ./build-multi-arch.sh --push
    ```

    **Other Options:**
    ```bash
    # Perform a clean build with no cache
    ./build-multi-arch.sh --no-cache
    ```

### Updating the Image

When you make changes and want to update the published image:

1. Update the version number in the `VERSION` file.
2. Run the build script with the `--push` flag:
   ```bash
   # Rebuild and push with no cache
   ./build-multi-arch.sh --no-cache --push
   ```

## Using the Image

Once published, users can pull the image on any supported platform:

```bash
docker pull autobyteus/chrome-vnc:latest
# or to pull a specific version
docker pull autobyteus/chrome-vnc:1.1.0
```

The correct architecture will be automatically selected based on the host system.

## VNC Access

The VNC server is configured without password authentication for convenience when running locally. No password is required when connecting with a VNC client. Screen locking and screensaver have been disabled to prevent session timeout issues.
