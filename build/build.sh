#!/bin/bash
set -e

# Retrieve the version from version.txt
VERSION=$(curl -s https://raw.githubusercontent.com/CyclotronResearchCentre/bidsme/dev/bidsme/version.txt)

# Build the Docker image using this version as the tag
echo "==> Building BIDSme Docker image version $VERSION"
docker build --build-arg BIDSME_VERSION=$VERSION -t bidsme:$VERSION .
echo "==> BIDSme Docker image built successfully with tag: bidsme:$VERSION"
