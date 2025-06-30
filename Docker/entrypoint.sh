#!/bin/sh
# If no arguments → open an interactive shell in /app
# Otherwise       → run bidsme with the given arguments

if [ "$#" -eq 0 ]; then
  echo "[INFO] Interactive BIDSme environment (type 'exit' to quit)"
  cd /app
  exec /bin/sh        # ou /bin/bash si tu ajoutes bash dans l'image
else
  exec bidsme "$@"
fi
