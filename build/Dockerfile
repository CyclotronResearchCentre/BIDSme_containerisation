# ---------- Build stage ----------
ARG PYTHON_VERSION=3.9-slim-bullseye
FROM python:${PYTHON_VERSION} AS builder
LABEL maintainer="SPITZ Bradley <spitzbradley@gmail.com>"

# Install required system dependencies for BIDSme
RUN apt-get update && apt-get install -y --no-install-recommends \
        tcl tk libffi-dev zlib1g dcm2niix git \
    && rm -rf /var/lib/apt/lists/*

# Clone BIDSme source code
WORKDIR /src
ARG BIDSME_VERSION=dev
RUN git clone https://github.com/CyclotronResearchCentre/bidsme \
 && cd bidsme && git checkout ${BIDSME_VERSION}

# Install Python dependencies including JupyterLab
WORKDIR /src/bidsme
RUN pip install --no-cache-dir jupyterlab && pip install --no-cache-dir ".[all]"

# ---------- Runtime stage ----------
FROM python:${PYTHON_VERSION}

# Install system dependencies again for runtime container
RUN apt-get update && apt-get install -y --no-install-recommends \
        tcl tk libffi-dev zlib1g dcm2niix \
    && rm -rf /var/lib/apt/lists/*

# Copy all installed Python packages from the builder image
COPY --from=builder /usr/local /usr/local

# Copy entrypoint script and init script for JupyterLab
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
COPY init_bidsme_lab.py /etc/jupyter/init_bidsme.py

# Set up non-root user with specified UID and GID
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID app && useradd -m -u $USER_ID -g app app

# Copy only the two notebooks into the image in a read-only location
COPY ./notebooks/bidsification_*.ipynb /opt/default_notebooks/
RUN chown -R app:app /opt/default_notebooks


# Create working and config directories with appropriate ownership
RUN mkdir -p /mnt && chown app:app /mnt
RUN mkdir -p /home/app/.jupyter && chown -R app:app /home/app

# Switch to non-root user
USER app

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    JUPYTER_PORT=8888 \
    JUPYTER_TOKEN=""

# Default working directory and port
WORKDIR /mnt
EXPOSE 8888

# Entrypoint handles all logic (prepare, process, lab, etc.)
ENTRYPOINT ["/entrypoint.sh"]
CMD []
