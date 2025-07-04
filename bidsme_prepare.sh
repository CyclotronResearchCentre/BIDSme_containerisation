# ~/.local/bin/bidsme_prepare
docker run --rm \
  -v "$PWD/rawdata":/app/rawdata \
  -v "$PWD/prepared":/app/prepared \
  bidsme:latest prepare "$@"

# Usage: Place this script in the same directory as the file containing the BIDS dataset
# and run it with the desired arguments.
# Example: ./bidsme_prepare.sh <additional-arguments>