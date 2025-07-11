#!/bin/sh
set -e

# ──────────────────────────────────────────────
# 1) no argument      => interactive shell
# 2) "prepare"        => bidsme prepare RAW PREP
# 3) "lab"            => JupyterLab
# 4) anything else    => passed directly to BIDSme
# ──────────────────────────────────────────────

if [ "$#" -eq 0 ]; then
  echo "[INFO] Interactive shell in /mnt"
  cd /mnt
  exec /bin/sh

elif [ "$1" = "prepare" ]; then
  shift
  echo "[INFO] Running bidsme prepare with default /mnt paths"
  exec bidsme prepare /mnt/rawdata /mnt/prepared "$@"

elif [ "$1" = "lab" ]; then
  shift
  echo "[INFO] Starting JupyterLab on port ${JUPYTER_PORT:-8888} ..."
  exec jupyter lab --ip=0.0.0.0 --port="${JUPYTER_PORT:-8888}" --no-browser --NotebookApp.token="$JUPYTER_TOKEN" --allow-root "$@"

else
  exec bidsme "$@"
fi
