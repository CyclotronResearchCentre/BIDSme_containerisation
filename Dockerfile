# ---------- Build stage ----------
ARG PYTHON_VERSION=3.9-alpine
FROM python:${PYTHON_VERSION} AS builder
LABEL maintainer="SPITZ Bradley <spitzbradley@gmail.com>"

# Dépendances de compilation
RUN apk add --no-cache --virtual .build-deps \
        build-base cmake git nodejs npm \
        python3-dev tcl-dev tk-dev libffi-dev jpeg-dev zlib-dev

# Compilation de dcm2niix
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/rordenlab/dcm2niix.git && \
    cd dcm2niix && mkdir build && cd build && cmake .. && make && \
    cp bin/dcm2niix /usr/local/bin/

# --- Installation des dépendances Python ---
WORKDIR /app
COPY bidsme /app

# --- INstallation de jupyterlab et de BIDSme ---
RUN pip install --no-cache-dir --prefix=/install jupyterlab
RUN pip install --no-cache-dir --prefix=/install .




# ---------- Runtime stage ----------
FROM python:${PYTHON_VERSION}

# Bibliothèques système nécessaires à l'exécution
RUN apk add --no-cache tcl tk libffi jpeg zlib

# dcm2niix compilé
COPY --from=builder /usr/local/bin/dcm2niix /usr/local/bin/

# Paquets Python (+ jupyter) installés sous /install
COPY --from=builder /install /usr/local

# Code source de l’application
COPY --from=builder /app /app

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Utilisateur non‑root
RUN addgroup -S app && adduser -S app -G app

# Donné la propriété de /app à l'utilisateur app
# Cela permet à l'utilisateur non-root d'écrire dans ce répertoire
# (nécessaire pour JupyterLab qui crée des fichiers de configuration)
# Si on ne le fait pas, JupyterLab ne pourra pas démarrer correctement
# et affichera une erreur de permission.
RUN chown -R app:app /app

USER app

# Variables d'environnement
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    JUPYTER_PORT=8888 \
    JUPYTER_TOKEN=""

WORKDIR /app
EXPOSE 8888

ENTRYPOINT ["/entrypoint.sh"]
CMD []
