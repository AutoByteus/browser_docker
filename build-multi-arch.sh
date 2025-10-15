#!/bin/bash
set -eo pipefail

# Configuration
IMAGE_NAME="autobyteus/chrome-vnc"
PLATFORMS="linux/amd64,linux/arm64"

# Read version from the VERSION file
if [ ! -f VERSION ]; then
  echo "Error: VERSION file not found!"
  exit 1
fi
VERSION=$(cat VERSION)
echo "Building version: $VERSION"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --no-cache)
      NO_CACHE="--no-cache"
      shift
      ;;
    --push)
      PUSH="--push"
      shift
      ;;
    --load)
      LOAD="--load"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Ensure --push and --load are not used together
if [ -n "$PUSH" ] && [ -n "$LOAD" ]; then
  echo "Error: --push and --load are mutually exclusive options."
  exit 1
fi

# Default to --load if --push is not specified
if [ -z "$PUSH" ]; then
  LOAD="--load"
  echo "No --push flag detected. Defaulting to build and load for local architecture."
fi

# Check if Docker BuildX is available
if ! docker buildx version &>/dev/null; then
  echo "Error: Docker BuildX is not available."
  echo "Please install or enable Docker BuildX before continuing."
  exit 1
fi

# Create a new builder if it doesn't exist
BUILDER_NAME="multi-platform-builder"
if ! docker buildx inspect "$BUILDER_NAME" &>/dev/null; then
  echo "Creating new BuildX builder: $BUILDER_NAME"
  docker buildx create --name "$BUILDER_NAME" --use
else
  docker buildx use "$BUILDER_NAME"
fi

# Make sure the builder is running and properly set up
docker buildx inspect --bootstrap

# Adjust platforms for local load
if [ -n "$LOAD" ]; then
  HOST_ARCH=$(uname -m)
  case "$HOST_ARCH" in
    x86_64)
      PLATFORMS="linux/amd64"
      ;;
    aarch64)
      PLATFORMS="linux/arm64"
      ;;
    *)
      echo "Error: Unsupported architecture for --load: $HOST_ARCH"
      exit 1
      ;;
  esac
  echo "Building for local architecture ($PLATFORMS) and loading into Docker daemon."
else
  echo "Building multi-architecture image for platforms: $PLATFORMS"
fi

echo "Image will be tagged as: $IMAGE_NAME:$VERSION and $IMAGE_NAME:latest"

if [ -n "$PUSH" ]; then
  echo "Image will be pushed to Docker Hub"
  echo "Ensure you are logged in with 'docker login' before proceeding"
  
  # Verify login status
  if ! docker info | grep -q "Username"; then
    echo "Error: Not logged in to Docker Hub. Please run 'docker login' first."
    exit 1
  fi
elif [ -n "$LOAD" ]; then
  echo "Image will be built and loaded into the local Docker daemon."
else
  # This case should ideally not be hit with the new logic, but left for safety.
  echo "Image will be built to cache only. Use --push to publish or --load to use locally."
fi

# Execute the build with both version and latest tags
docker buildx build \
  $PUSH \
  $LOAD \
  $NO_CACHE \
  --platform "$PLATFORMS" \
  --tag "$IMAGE_NAME:$VERSION" \
  --tag "$IMAGE_NAME:latest" \
  .

echo "Build completed successfully!"
if [ -n "$PUSH" ]; then
  echo "Multi-architecture image pushed to Docker Hub with tags $VERSION and latest."
  echo "Users can now pull this image on any supported platform."
elif [ -n "$LOAD" ]; then
  echo "Image loaded into local Docker daemon with tags $VERSION and latest."
  echo "You can check with 'docker images' and run it locally."
else
  echo "Image built to cache. Use --push to publish to Docker Hub or --load to use it locally."
fi
