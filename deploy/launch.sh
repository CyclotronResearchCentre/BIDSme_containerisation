#!/bin/bash

MODE=${1:-prod}
export MODE=$MODE

echo "[INFO] Launching BIDSme in '$MODE' mode..."

# Replace environment variables in the docker-compose template
envsubst < docker-compose.yml.template > docker-compose.generated.yml

# Run with the generated file
docker compose -f docker-compose.generated.yml run -p 8888:8888 bidsme lab $MODE
