# ---------- Build stage ----------
ARG PYTHON_VERSION=3.9-slim-bullseye
FROM python:${PYTHON_VERSION} AS builder
LABEL maintainer="SPITZ Bradley <spitzbradley@gmail.com>"

# Install system dependencies required to build BIDSme
RUN apt-get update && apt-get install -y --no-install-recommends \
        tcl tk libffi-dev zlib1g dcm2niix git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /src

# Clone BIDSme and checkout specific version (passed by --build-arg)
ARG BIDSME_VERSION=dev
RUN git clone https://github.com/CyclotronResearchCentre/bidsme \
 && cd bidsme && git checkout ${BIDSME_VERSION}

# Install Python dependencies
WORKDIR /src/bidsme
RUN pip install --no-cache-dir jupyterlab \
 && pip install --no-cache-dir ".[all]"


# ---------- Runtime stage ----------
FROM python:${PYTHON_VERSION}

# Install only what is strictly required at runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
        tcl tk libffi-dev zlib1g dcm2niix \
    && rm -rf /var/lib/apt/lists/*

# Copy installed Python packages from builder
COPY --from=builder /usr/local /usr/local

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create non-root user (helps with file permissions when mounting volumes)
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID app && useradd -m -u $USER_ID -g app app

# Create a directory for mounting data
# and set permissions for the non-root user
RUN mkdir -p /mnt && chown app:app /mnt

# Switch to non-root user
USER app

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    JUPYTER_PORT=8888 \
    JUPYTER_TOKEN=""

# Set default work directory and expose Jupyter port
WORKDIR /mnt
EXPOSE 8888

ENTRYPOINT ["/entrypoint.sh"]
CMD []
