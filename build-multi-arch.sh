#!/bin/bash
set -eo pipefail

# Configuration
IMAGE_NAME="autobyteus/chrome-vnc"
TAG="latest"
PLATFORMS="linux/amd64,linux/arm64"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --tag)
      TAG="$2"
      shift 2
      ;;
    --no-cache)
      NO_CACHE="--no-cache"
      shift
      ;;
    --push)
      PUSH="--push"
      shift
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

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

# Build (and optionally push) the multi-architecture image
echo "Building multi-architecture image for platforms: $PLATFORMS"
echo "Image: $IMAGE_NAME:$TAG"

if [ -n "$PUSH" ]; then
  echo "Image will be pushed to Docker Hub"
  echo "Make sure you're logged in with 'docker login' before proceeding"
  
  # Verify login status
  if ! docker info | grep -q "Username"; then
    echo "Error: Not logged in to Docker Hub. Please run 'docker login' first."
    exit 1
  fi
else
  echo "Image will be built but not pushed (use --push to push to registry)"
fi

# Execute the build
docker buildx build \
  $PUSH \
  $NO_CACHE \
  --platform "$PLATFORMS" \
  --tag "$IMAGE_NAME:$TAG" \
  .

echo "Build completed successfully!"
if [ -n "$PUSH" ]; then
  echo "Multi-architecture image pushed to: $IMAGE_NAME:$TAG"
  echo "Users can now pull this image on any supported platform"
else
  echo "Image built but not pushed. Run with --push to publish to Docker Hub."
fi
