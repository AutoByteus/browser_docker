# Building Multi-Architecture Docker Images

This document explains how to build Docker images that work across multiple CPU architectures, specifically targeting both x86_64/amd64 (Intel/AMD) and ARM64 (Apple M1/M2) platforms.

## Prerequisites

Ensure you have Docker installed with BuildX support:

- Docker Desktop (Mac/Windows) already includes BuildX
- On Linux, you may need to install it separately

## Setting Up Docker BuildX

1. Check available BuildX builders:

```bash
docker buildx ls
```

2. Create a new BuildX builder with multi-architecture support:

```bash
docker buildx create --name multi-arch-builder --use
```

3. Verify it's set as default and supports multiple platforms:

```bash
docker buildx inspect
```

## Building Multi-Architecture Base Image

Follow these steps to build the `autobyteus/chrome-vnc` base image for multiple architectures:

1. Navigate to the base image directory:
```bash
cd docker-browser-test
```

2. Build and push the multi-architecture image directly to Docker Hub:
```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  -t autobyteus/chrome-vnc:latest \
  --push .
```

This command builds the image for both Intel/AMD (amd64) and Apple M1/M2 (arm64) architectures and pushes it to Docker Hub.

## Building Multi-Architecture LLM Server Image

After building the multi-architecture base image, you can build the LLM server image:

1. Navigate to the LLM server directory:
```bash
cd autobyteus_rpa_llm_server/docker
```

2. Build and push the multi-architecture LLM server image:
```bash
docker buildx build --platform linux/amd64,linux/arm64 \
  -t autobyteus/llm-server:latest \
  --push .
```

## Verifying Multi-Architecture Images

To verify that your images support multiple architectures:

```bash
docker buildx imagetools inspect autobyteus/chrome-vnc:latest
docker buildx imagetools inspect autobyteus/llm-server:latest
```

These commands should show that the images support both `linux/amd64` and `linux/arm64` platforms.

## Important Notes and Troubleshooting

1. **First-time setup**: BuildX may need to set up QEMU for cross-platform emulation the first time you use it:
```bash
docker run --privileged --rm tonistiigi/binfmt --install all
```

2. **Build times**: Building for multiple architectures takes longer than single-architecture builds.

3. **Runtime error potential**: Even with multi-architecture builds, some applications (especially those with native dependencies) might still have issues. Test thoroughly on all target platforms.

4. **Resource usage**: Building for ARM64 on an x86 machine (or vice versa) uses emulation which is resource-intensive and slower.

5. **Architecture-specific Dockerfiles**: For complex applications, you might need separate Dockerfiles for different architectures. Use BuildX's `--file` option to specify alternative Dockerfiles.

## Advanced: Using Architecture-Specific Base Images

If applications require different setups for different architectures, you can use architecture-specific conditionals in your Dockerfile:

```dockerfile
FROM --platform=$BUILDPLATFORM ubuntu:22.04 AS builder

# Install architecture-specific dependencies
RUN if [ "$(uname -m)" = "x86_64" ]; then \
      apt-get update && apt-get install -y some-x86-specific-package; \
    elif [ "$(uname -m)" = "aarch64" ]; then \
      apt-get update && apt-get install -y some-arm-specific-package; \
    fi

# Continue with common build steps...

FROM --platform=$TARGETPLATFORM ubuntu:22.04
# Use built artifacts from builder stage...
```

## Conclusion

By following these steps, you can create Docker images that work seamlessly across Intel/AMD (x86_64) and Apple M1/M2 (ARM64) architectures. This approach ensures consistent behavior regardless of where your containers are built or run.
