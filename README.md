
## Publishing to Docker Hub

Follow these steps to publish your own version of this image to Docker Hub:

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

### Updating the Image

When you make changes and want to update the published image:

1. Rebuild with no cache:
```bash
docker-compose build --no-cache
```

2. Remove old images if needed:
```bash
# List images
docker images

# Remove specific images
docker rmi autobyteus-base:latest
docker rmi autobyteus/chrome-vnc:latest

# Or force remove if they're in use
docker rmi -f autobyteus-base:latest autobyteus/chrome-vnc:latest
```

3. Tag and push again:
```bash
docker tag autobyteus-base autobyteus/chrome-vnc:latest
docker push autobyteus/chrome-vnc:latest
```