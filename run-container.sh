#!/bin/bash
set -eo pipefail

# Configuration
IMAGE_NAME="autobyteus/chrome-vnc"
TAG="latest"
CONTAINER_NAME="chrome-vnc"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --tag)
      TAG="$2"
      shift 2
      ;;
    --name)
      CONTAINER_NAME="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

echo "Pulling the latest multi-architecture image..."
docker pull "$IMAGE_NAME:$TAG"

echo "Starting container: $CONTAINER_NAME"
docker run -d \
  --name "$CONTAINER_NAME" \
  --cap-add SYS_ADMIN \
  --security-opt seccomp=unconfined \
  -p 5900:5900 \
  -p 9223:9223 \
  -e DISPLAY=:99 \
  --restart unless-stopped \
  "$IMAGE_NAME:$TAG"

echo "Container started successfully!"
echo "VNC accessible at: localhost:5900 (password: mysecretpassword)"
echo "Chrome debugging port: 9223"
