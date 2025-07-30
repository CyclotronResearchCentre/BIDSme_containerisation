#!/bin/sh
set -e

rm -rf /home/app/.local/share/jupyter/runtime/*

echo "[INFO] Checking permissions on /mnt and mounted folders..."

OWNER=$(stat -c '%U' /mnt)
if [ "$OWNER" != "app" ]; then
  echo "[WARN] /mnt is owned by $OWNER, but should be 'app'. Please verify volume mount permissions."
fi


# ──────────────────────────────────────────────
# 1) no argument      => interactive shell
# 2) "prepare"        => bidsme prepare RAW PREP
# 3) "process"        => bidsme process PREP BIDSIFIED
# 4) "map"            => bidsme map PREP BIDSIFIED
# 5) "bidsify"        => bidsme bidsify PREP BIDSIFIED
# 6) "lab"            => JupyterLab
# 7) anything else    => passed directly to BIDSme
# ──────────────────────────────────────────────

if [ "$#" -eq 0 ]; then
  echo "[INFO] Interactive shell in /mnt"
  cd /mnt
  exec bash

elif [ "$1" = "prepare" ]; then
  shift
  echo "[INFO] Running bidsme prepare with default /mnt paths"
  exec bidsme prepare /mnt/rawdata /mnt/prepared "$@"

elif [ "$1" = "process" ]; then
  shift
  echo "[INFO] Running bidsme process with default /mnt paths"
  exec bidsme process /mnt/prepared /mnt/bidsified "$@"

elif [ "$1" = "map" ]; then
  shift
  echo "[INFO] Running bidsme map with default /mnt paths"
  exec bidsme map /mnt/prepared /mnt/bidsified "$@"

elif [ "$1" = "bidsify" ]; then
  shift
  echo "[INFO] Running bidsme bidsify with default /mnt paths"
  exec bidsme bidsify /mnt/prepared /mnt/bidsified "$@"

elif [ "$1" = "lab" ]; then
  shift

  MODE=${1:-prod}
  if [ -n "$1" ]; then
    shift  # only shift if a mode was provided
  fi


  NOTEBOOKS_SRC="/opt/default_notebooks"


if [ "$MODE" = "prod" ]; then
  export BIDSME_PRODUCTION="true"
  NOTEBOOK_NAME="bidsification_prod.ipynb"
elif [ "$MODE" = "dev" ]; then
  export BIDSME_PRODUCTION="false"
  NOTEBOOK_NAME="bidsification_dev.ipynb"
else
  echo "[ERROR] Unknown lab mode: $MODE (use 'dev' or 'prod')"
  exit 1
fi

# Copy the appropriate notebook to the target location
TARGET_NOTEBOOK="/mnt/${NOTEBOOK_NAME}"
if [ ! -f "$TARGET_NOTEBOOK" ]; then
  echo "[INFO] Copying default notebook to $TARGET_NOTEBOOK"
  cp "${NOTEBOOKS_SRC}/${NOTEBOOK_NAME}" "$TARGET_NOTEBOOK"
else
  echo "[INFO] Notebook already exists at $TARGET_NOTEBOOK"
fi

  export PYTHONSTARTUP="/etc/jupyter/init_bidsme.py"

  # Launch JupyterLab normally
  exec jupyter lab \
    --ip=0.0.0.0 --port="${JUPYTER_PORT:-8888}" \
    --no-browser --NotebookApp.token="$JUPYTER_TOKEN" \
    --allow-root "$@"

fi
