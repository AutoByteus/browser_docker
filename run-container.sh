#!/bin/bash
set -eo pipefail

# Configuration
IMAGE_NAME="autobyteus/chrome-vnc"
TAG="latest"
CONTAINER_NAME="chrome-vnc"
VNC_PORT=5900
DEBUG_PORT=9223

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
    --vnc-port)
      VNC_PORT="$2"
      shift 2
      ;;
    --debug-port)
      DEBUG_PORT="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Check if image exists locally; if not, pull it from Docker Hub.
if ! docker image inspect "$IMAGE_NAME:$TAG" &> /dev/null; then
  echo "Image '$IMAGE_NAME:$TAG' not found locally. Pulling from Docker Hub..."
  docker pull "$IMAGE_NAME:$TAG"
else
  echo "Using existing local image: $IMAGE_NAME:$TAG"
fi

# Stop and remove any existing container with the same name
if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Container '$CONTAINER_NAME' is already running. Stopping and removing it."
    docker stop "$CONTAINER_NAME" > /dev/null
    docker rm "$CONTAINER_NAME" > /dev/null
elif [ "$(docker ps -aq -f status=exited -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Removing existing stopped container '$CONTAINER_NAME'."
    docker rm "$CONTAINER_NAME" > /dev/null
fi

echo "Starting container: $CONTAINER_NAME"
docker run -d \
  --name "$CONTAINER_NAME" \
  --cap-add SYS_ADMIN \
  --security-opt seccomp=unconfined \
  -p "$VNC_PORT":5900 \
  -p "$DEBUG_PORT":9223 \
  -e DISPLAY=:99 \
  --restart unless-stopped \
  "$IMAGE_NAME:$TAG"

echo "Container started successfully!"
echo "VNC accessible at: localhost:$VNC_PORT (no password required)"
echo "Chrome debugging port: $DEBUG_PORT"
