# ---------- Build stage ----------

# Utilisation d'une image alpine légère avec Python 3.9 (version configurable via ARG)
ARG PYTHON_VERSION=3.9-alpine
FROM python:${PYTHON_VERSION} AS builder
LABEL maintainer="SPITZ Bradley <spitzbradley@gmail.com>"

# Installation des dépendances nécessaires à la compilation et au build des paquets Python
RUN apk add --no-cache --virtual .build-deps \
        build-base cmake git nodejs npm \
        python3-dev tcl-dev tk-dev libffi-dev jpeg-dev zlib-dev

# Téléchargement et compilation de dcm2niix (outil pour convertir DICOM en NIfTI)
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/rordenlab/dcm2niix.git && \
    cd dcm2niix && mkdir build && cd build && cmake .. && make && \
    cp bin/dcm2niix /usr/local/bin/

WORKDIR /app
COPY bidsme /app
RUN pip install --no-cache-dir --prefix=/install .

# Copie des sources du projet dans le dossier /app dans l'image, en omettant les fichiers inutiles cités dans .dockerignore
COPY bidsme /app




# ---------- Runtime stage ----------

FROM python:${PYTHON_VERSION}

# Installation des dépendances nécessaires à l’exécution (bibliothèques système)
RUN apk add --no-cache tcl tk libffi jpeg zlib

# Copie de l'exécutable dcm2niix compilé dans l’image runtime
COPY --from=builder /usr/local/bin/dcm2niix /usr/local/bin/

# Copie des paquets Python installés lors de la phase de build
COPY --from=builder /install /usr/local

# Copie des sources de l’application dans le conteneur
COPY --from=builder /app /app

# Copie du script d’entrée et mise en mode exécutable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Création d’un utilisateur non-root pour exécuter le conteneur plus sûrement
RUN addgroup -S app && adduser -S app -G app
USER app

# Variables d’environnement pour le comportement Python et Jupyter
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1 \
    JUPYTER_PORT=8888 JUPYTER_TOKEN=""

# Définition du dossier de travail dans le conteneur
WORKDIR /app

# Exposition du port 8888 (pour Jupyter)
EXPOSE 8888

# Script d’entrée du conteneur
ENTRYPOINT ["/entrypoint.sh"]

# Commande par défaut (ici rien car entrypoint.sh gère déjà)
CMD []
