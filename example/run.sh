#!/bin/sh

EXAMPLE_DIR="$(dirname "$0")"
EXAMPLE_DIR="$(realpath "$EXAMPLE_DIR")"
ROOT_DIR="$(dirname "$EXAMPLE_DIR")"

podman build -t localhost/tinyproxy "$ROOT_DIR"

MSYS_NO_PATHCONV=1 podman run --rm -it \
    -p 8888:8888 \
    -v "$EXAMPLE_DIR/tinyproxy.conf:/etc/tinyproxy/tinyproxy.conf:ro" \
    localhost/tinyproxy:latest
