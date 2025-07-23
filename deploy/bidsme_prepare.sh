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

# Run the BIDSme prepare command in the container with proper UID/GID
docker run --rm \
  -v "$PWD/rawdata":/app/rawdata:ro \
  -v "$PWD/prepared":/app/prepared \
  bidsme:latest prepare "$@"

# Usage: Place this script in the same directory as the file containing the BIDS dataset
# and run it with the desired arguments.
# Example: ./bidsme_prepare.sh <additional-arguments>
