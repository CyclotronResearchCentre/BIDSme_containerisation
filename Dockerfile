# ---------- Build stage ----------
ARG PYTHON_VERSION=3.9-alpine
FROM python:${PYTHON_VERSION} AS builder
LABEL maintainer="SPITZ Bradley <spitzbradley@gmail.com>"

# Compilation dependencies
RUN apk add --no-cache --virtual .build-deps \
        build-base cmake git nodejs npm \
        python3-dev tcl-dev tk-dev libffi-dev zlib-dev

# Compilation of dcm2niix
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/rordenlab/dcm2niix.git && \
    cd dcm2niix && mkdir build && cd build && cmake .. && make && \
    cp bin/dcm2niix /usr/local/bin/


WORKDIR /mnt
COPY bidsme /mnt

# Installation of jupyterlab and BIDSme 
RUN pip install --no-cache-dir --prefix=/install jupyterlab
RUN pip install --no-cache-dir --prefix=/install .



# ---------- Runtime stage ----------
FROM python:${PYTHON_VERSION}

# Required system libraries at runtime
RUN apk add --no-cache tcl tk libffi zlib

# Copy compiled dcm2niix
COPY --from=builder /usr/local/bin/dcm2niix /usr/local/bin/

# Copy installed Python packages
COPY --from=builder /install /usr/local

# Copy application source
COPY --from=builder /mnt /mnt

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Root issue
ARG UID=1000
ARG GID=1000
RUN addgroup -g $GID app && adduser -u $UID -G app -D app
USER app


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
