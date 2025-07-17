# ---------- Build stage ----------
ARG PYTHON_VERSION=3.9-slim
FROM python:${PYTHON_VERSION} AS builder
LABEL maintainer="SPITZ Bradley <spitzbradley@gmail.com>"

RUN apt-get update && apt-get install -y --no-install-recommends \
        tcl tk libffi-dev zlib1g dcm2niix \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /mnt
COPY bidsme /mnt

# Install jupyterlab and BIDSme into a custom prefix
RUN pip install --no-cache-dir --prefix=/install jupyterlab
RUN pip install --no-cache-dir --prefix=/install .



# ---------- Runtime stage ----------
FROM python:${PYTHON_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
        tcl tk libffi-dev zlib1g dcm2niix \
    && rm -rf /var/lib/apt/lists/*


# Copy installed Python packages from build stage
COPY --from=builder /install /usr/local

# Copy application source code
COPY --from=builder /mnt /mnt

# Copy entrypoint script and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create app user with specified UID and GID
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID app && useradd -m -u $USER_ID -g app app

USER app

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    JUPYTER_PORT=8888 \
    JUPYTER_TOKEN=""

WORKDIR /mnt
EXPOSE 8888

ENTRYPOINT ["/entrypoint.sh"]
CMD []
