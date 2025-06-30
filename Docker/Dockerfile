############################################################
# Multi-stage build with Alpine and compilation of dcm2niix #
############################################################

#########################
# 1. Build stage        #
#########################
FROM python:3.9-alpine AS builder

# Compilation tools and libs
RUN apk add --no-cache \
    build-base cmake git \
    python3-dev tcl-dev tk-dev libffi-dev jpeg-dev zlib-dev

# ---- Build dcm2niix ----
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/rordenlab/dcm2niix.git && \
    cd dcm2niix && mkdir build && cd build && \
    cmake .. && make && \
    cp bin/dcm2niix /usr/local/bin/

# ---- Install Python deps (including nibabel & pydicom) ----
WORKDIR /app

COPY bidsme /app
# Runtime stage
COPY Docker/entrypoint.sh /entrypoint.sh

RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir --prefix=/install . nibabel pydicom && \
    find /install -name '*.pyc' -delete && \
    find /install -type d -name '__pycache__' -exec rm -r {} +

#############################
# 2. Final runtime image    #
#############################
FROM python:3.9-alpine

RUN apk add --no-cache tcl tk libffi jpeg zlib

# dcm2niix and Python deps
COPY --from=builder /usr/local/bin/dcm2niix /usr/local/bin/
COPY --from=builder /install /usr/local

# entrypoint copied FROM builder
COPY --from=builder /entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Environment
ENV PATH="/usr/local/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app


# ---- DO NOT declare VOLUME ----
# Users will bind-mount their own folders.
ENTRYPOINT ["/entrypoint.sh"]
CMD []
