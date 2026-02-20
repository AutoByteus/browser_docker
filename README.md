# Docker Browser Test Environment

This repository contains a Docker setup for a browser environment with VNC access, optimized for multi-architecture builds.

## Features
- Ubuntu 22.04 with XFCE4 desktop environment
- Chromium browser pre-installed and configured
- Python 3.11, Node.js 22, and Yarn
- TigerVNC (`Xvnc`) server for remote desktop access
- Screen lock/screensaver disabled for uninterrupted operation
- Multi-architecture support (AMD64 and ARM64)
- Optional `zh` locale tag with Chinese fonts installed and fcitx5 enabled (English keyboard stays default; toggle Chinese with `Ctrl+Space`).

## Prerequisites

This project uses Docker BuildX to create images that run on both Intel/AMD (amd64) and Apple Silicon (arm64) architectures.

- **Docker with BuildX**: Ensure you have a recent version of Docker installed. Docker Desktop (Mac/Windows) includes BuildX by default. On Linux, you may need to install or enable it separately.

## Building the Image

The included `build-multi-arch.sh` script automates the build process and can now produce both the default (English) image and a `zh` variant with Chinese fonts/input pre-configured.

1.  **Set the Version**: Before building, update the `VERSION` file in this directory with the desired semantic version (e.g., `1.2.0`). This file is the single source of truth for versioning.

2.  **Run the Build Script**: The script will automatically read the `VERSION` file and tag the image accordingly.

    **For Local Development (Default):**
    Running the script without any flags will build the image for your machine's architecture and load it directly into your local Docker daemon.
    ```bash
    # Build for your local architecture and load into Docker
    ./build-multi-arch.sh
    ```
    The image will then be available in `docker images`.

    **For Publishing:**
    To build the multi-architecture image and push it to Docker Hub, use the `--push` flag. This requires you to be logged in via `docker login` first.
    ```bash
    # Build for all supported architectures and push to Docker Hub
    ./build-multi-arch.sh --push
    ```

    **Other Options:**
    ```bash
    # Perform a clean build with no cache
    ./build-multi-arch.sh --no-cache
    ```

### Building the Chinese (`zh`) Variant

Pass `--variant zh` to the build script to install Chinese fonts, locales, and fcitx5. The script automatically tags the result as `autobyteus/chrome-vnc:<version>-zh` and `autobyteus/chrome-vnc:zh`.

```bash
# Build the zh variant for your local architecture and load it into Docker
./build-multi-arch.sh --variant zh

# Build multi-arch zh images and push them
./build-multi-arch.sh --variant zh --push
```

Inside the zh image, English remains the default input method. Users can press `Ctrl+Space` (fcitx default) or click the fcitx tray icon to toggle Chinese Pinyin input and render Chinese websites with preinstalled fonts.

### First-Time BuildX Setup / Troubleshooting

The `build-multi-arch.sh` script attempts to create and use a dedicated BuildX builder named `multi-platform-builder`. If you encounter issues, you may need to run these setup commands manually.

1.  **Create a builder** (if it doesn't exist):
    ```bash
    docker buildx create --name multi-platform-builder --use
    ```

2.  **Enable QEMU for cross-platform emulation** (required for first-time setup):
    ```bash
    docker run --privileged --rm tonistiigi/binfmt --install all
    ```

### Verifying the Multi-Architecture Build

After pushing an image, you can verify that it supports multiple architectures with the following command:

```bash
docker buildx imagetools inspect autobyteus/chrome-vnc:latest
```
The output should list both `linux/amd64` and `linux/arm64` under "Manifests".

## Running a Standalone Container

After building the image locally or pulling it from Docker Hub, you can easily start a standalone container for direct use or testing.

1.  **Use the Run Script:** The included `run-container.sh` script is the recommended way to start the container. It will automatically use your locally built image or pull from Docker Hub if a local version isn't found.
    ```bash
    ./run-container.sh
    ```

2.  **Accessing the Container:** Once started, you can access the container's desktop environment:
    *   **VNC (TigerVNC/Xvnc):** Connect your VNC client to `localhost:5900` (or your custom port). No password is required.
    *   **Chrome Debugging:** The browser's remote debugging port is available at `localhost:9223` (or your custom port).
    *   **Chinese Input (zh tag only):** fcitx5 autostarts in the panel; press `Ctrl+Space` to toggle between the default English keyboard and Chinese Pinyin, or click the fcitx icon to pick another layout.

3.  **Customization and Troubleshooting:**

    **Screen Resolution:**
    The default screen resolution is `1920x1080x24`. You can override this using the `--resolution` flag. The format is `WIDTHxHEIGHTxDEPTH`.
    ```bash
    # Run with a custom resolution of 1366x768
    ./run-container.sh --resolution 1366x768x24
    ```

    **Port Conflicts:**
    If you get a "port is already allocated" error, you can specify different host ports using flags:
    ```bash
    # Run VNC on host port 5902 and the debug port on 9224
    ./run-container.sh --vnc-port 5902 --debug-port 9224
    ```

    **Other Customizations:**
    You can also specify a custom tag or container name:
    ```bash
    # Run a specific version and give the container a custom name
    ./run-container.sh --tag 1.2.0 --name my-custom-container

    # Run the Chinese-enabled image (built or pulled as autobyteus/chrome-vnc:zh)
    ./run-container.sh --tag zh
    ```

## Reliable Recovery After Host/Daemon Restart

If a container is stopped abruptly (power loss, daemon crash), VNC can fail to come back with:

```text
Server is already active for display 99
```

Root cause is usually stale X lock/socket files:
- `/tmp/.X99-lock`
- `/tmp/.X11-unix/X99`

This image now starts TigerVNC via `/usr/local/bin/start-vnc.sh`, which removes stale lock/socket files when they are not owned by a live X server process.

For already-running older containers (built before this fix), recover manually:

```bash
docker exec <container> sh -lc 'rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 && supervisorctl restart tigervnc xfce chrome copyq'
```

To make recovery permanent, rebuild/pull the updated image and recreate containers.
