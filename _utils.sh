#!/bin/sh

set -eu

if [ -z "${ROOT_DIR:-}" ]; then
    exit 67
fi

EXAMPLE_DIR="$ROOT_DIR/example"
DIST_DIR="$ROOT_DIR/dist"

GIT_URL="https://github.com/zyrouge/tinyproxy-container-image.git"
IMAGE_NAME="ghcr.io/zyrouge/tinyproxy"
LOCAL_IMAGE_NAME="localhost/tinyproxy"

TINYPROXY_GIT_URL="https://github.com/tinyproxy/tinyproxy"
