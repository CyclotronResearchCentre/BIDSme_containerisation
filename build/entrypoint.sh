#!/usr/bin/env bash
set -e

# ──────────────────────────────────────────────
# Display container help immediately if requested
# ──────────────────────────────────────────────
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
  cat <<'EOF'
BIDSme Docker Container Help
----------------------------

This container provides a ready-to-use environment for running BIDSme
with default configuration and JupyterLab notebooks.

Basic usage:
  docker run -v <local_path>:/mnt/folder_name bidsme [command] [options]

Commands:
  --help, -h       → Show this container help
  <no argument>    → Start an interactive shell in /mnt
  prepare          → Run "bidsme prepare /mnt/rawdata /mnt/prepared"
  process          → Run "bidsme process /mnt/prepared /mnt/bidsified"
  map              → Run "bidsme map /mnt/prepared /mnt/bidsified"
  bidsify          → Run "bidsme bidsify /mnt/prepared /mnt/bidsified"
  lab [prod|dev]   → Launch JupyterLab in production or development mode
                     Copies the default notebook to /mnt if it doesn't exist
  <anything else>  → Passed directly to BIDSme CLI

Note:
  These commands are valid both with 'docker run' and Docker Compose.

Default configuration:
  If /mnt/configuration is empty, the container automatically clones the
  default template from:
    https://gitlab.uliege.be/CyclotronResearchCentre/Public/bidstools/bidsme/bidsification-template
  The .git folder is removed to make it independent. 

Examples:
  docker run -it -v "$PWD/rawdata_prod:/mnt/rawdata:ro" \
    -v "$PWD/prepared_prod:/mnt/prepared" \
    -v "$PWD/bidsified_prod:/mnt/bidsified" \
    -v "$PWD/configuration:/mnt/configuration" \
    bidsme:<version> <arguments>

Documentation & source:
  Container documentation:
    https://github.com/CyclotronResearchCentre/BIDSme_containerisation/
  BIDSme documentation:
    https://github.com/CyclotronResearchCentre/bidsme
EOF
  exit 0
fi

# ──────────────────────────────────────────────
# Permissions check
# ──────────────────────────────────────────────
echo "[INFO] Checking permissions on /mnt and mounted folders..."
OWNER=$(stat -c '%U' /mnt)
if [ "$OWNER" != "app" ]; then
  echo "[WARN] /mnt is owned by $OWNER, but should be 'app'. Please verify volume mount permissions."
fi

# ──────────────────────────────────────────────
# Setup configuration folder if empty
# ──────────────────────────────────────────────
CONFIG_DIR="/mnt/configuration"
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p "$CONFIG_DIR"
  chown app:app "$CONFIG_DIR"
fi

if [ -z "$(ls -A "$CONFIG_DIR")" ]; then
  echo "[INFO] Configuration directory is empty. Cloning default template..."
  git clone --depth 1 https://gitlab.uliege.be/CyclotronResearchCentre/Public/bidstools/bidsme/bidsification-template "$CONFIG_DIR"
  rm -rf "$CONFIG_DIR/.git"
  echo "[INFO] Template cloned and detached from remote."
else
  echo "[INFO] Configuration directory already contains files. Skipping clone."
fi

# ──────────────────────────────────────────────
# Command overview / mapping
# ──────────────────────────────────────────────
# 1) no argument      → interactive shell in /mnt
# 2) "prepare"        → bidsme prepare /mnt/rawdata /mnt/prepared
# 3) "process"        → bidsme process /mnt/prepared /mnt/bidsified
# 4) "map"            → bidsme map /mnt/prepared /mnt/bidsified
# 5) "bidsify"        → bidsme bidsify /mnt/prepared /mnt/bidsified
# 6) "lab [prod|dev]" → launch JupyterLab (copies default notebook if missing)
# 7) anything else    → passed directly to BIDSme CLI

# ──────────────────────────────────────────────
# Handle commands
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
  if [ -n "$1" ]; then shift; fi

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

  TARGET_NOTEBOOK="/mnt/${NOTEBOOK_NAME}"
  if [ ! -f "$TARGET_NOTEBOOK" ]; then
    echo "[INFO] Copying default notebook to $TARGET_NOTEBOOK"
    cp "${NOTEBOOKS_SRC}/${NOTEBOOK_NAME}" "$TARGET_NOTEBOOK"
  else
    echo "[INFO] Notebook already exists at $TARGET_NOTEBOOK"
  fi

  export PYTHONSTARTUP="/etc/jupyter/init_bidsme.py"

  exec jupyter lab \
    --ip=0.0.0.0 --port="${JUPYTER_PORT:-8888}" \
    --no-browser --NotebookApp.token="$JUPYTER_TOKEN" \
    --allow-root "$@"

else
  # Anything else is passed directly to bidsme CLI
  exec bidsme "$@"
fi
