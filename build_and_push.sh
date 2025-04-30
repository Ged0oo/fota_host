#!/bin/bash

# Strict error handling
set -euo pipefail

# Check for both arguments
if [ $# -ne 2 ]; then
  echo "Usage: $0 <version> <target>"
  echo "Example: $0 v1.2.3 <central, front, rear>"
  exit 1
fi

VERSION=$1
TARGET=$2
USER=ged0oo
REPO=fota-host

# Validate target
case "$TARGET" in
  central)
    SERVICES=(acc bbs ebs msn)
    DOCKER_DIR="./ecu_00_central/central_container"
    ;;
  front)
    SERVICES=(abc abb cde)
    DOCKER_DIR="./ecu_01_front/front_container"
    ;;
  rear)
    SERVICES=(sdf xyz)
    DOCKER_DIR="./ecu_02_rear/rear_container"
    ;;
  *)
    echo "Invalid target: $TARGET"
    echo "Valid targets are: central, front, rear"
    exit 1
    ;;
esac

# Build and push for each service
for SERVICE in "${SERVICES[@]}"; do
  echo "Building and pushing $SERVICE for $TARGET..."
  
  # Build docker image
  docker build \
    -f "$DOCKER_DIR/Dockerfile.$SERVICE" \
    -t "ghcr.io/$USER/$REPO-$SERVICE:$VERSION" \
    "$DOCKER_DIR"
  
  # Push docker image
  docker push "ghcr.io/$USER/$REPO-$SERVICE:$VERSION"
  
  echo "Successfully built and pushed $SERVICE:$VERSION"
done

echo "Completed building and pushing images for $TARGET"