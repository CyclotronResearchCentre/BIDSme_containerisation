#!/bin/bash
# ~/.local/bin/bidsme_prepare

# Ensure required folders exist
if [ ! -d "$PWD/rawdata" ]; then
  echo "[ERROR] Missing directory: rawdata"
  exit 1
fi

if [ ! -d "$PWD/prepared" ]; then
  echo "[ERROR] Missing directory: prepared"
  exit 1
fi

# Set user and group ID from current host user
USER_ID=$(id -u)
GROUP_ID=$(id -g)

# Run the BIDSme prepare command in the container with proper UID/GID
docker run --rm \
  --user "$USER_ID:$GROUP_ID" \
  -v "$PWD/rawdata":/app/rawdata:ro \
  -v "$PWD/prepared":/app/prepared \
  bidsme:latest prepare "$@"

# Usage: Place this script in the same directory as the file containing the BIDS dataset
# and run it with the desired arguments.
# Example: ./bidsme_prepare.sh <additional-arguments>
