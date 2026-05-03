#!/bin/sh

set -eu

ROOT_DIR="$(dirname "$(realpath "$0")")"

. "$ROOT_DIR/_utils.sh"

get_release_info_key() {
    if ! [ -f "$DIST_DIR/$1" ]; then
        "$ROOT_DIR/release-info.sh"
    fi
    cat "$DIST_DIR/$1"
}

echo "Fetching version..."
if [ -z "${TINYPROXY_VERSION:-}" ]; then
    TINYPROXY_VERSION="$(get_release_info_key version.txt)"
fi

echo "Fetching revision..."
if [ -z "${TINYPROXY_REVISION:-}" ]; then
    TINYPROXY_REVISION="$(get_release_info_key revision.txt)"
fi

CREATED=$(date -u +"%Y-%m-%dT%H:%M:%S%z")

echo "Removing old image..."
podman rmi "$LOCAL_IMAGE_NAME:$TINYPROXY_VERSION" > /dev/null 2>&1 || true

echo "Removing old manifest..."
podman manifest rm "$LOCAL_IMAGE_NAME:$TINYPROXY_VERSION" > /dev/null 2>&1 || true

echo "Creating manifest..."
podman manifest create "$LOCAL_IMAGE_NAME:$TINYPROXY_VERSION"

echo "Building image..."
podman build \
    --build-arg CREATED="$CREATED" \
    --build-arg TINYPROXY_VERSION="$TINYPROXY_VERSION" \
    --build-arg TINYPROXY_REVISION="$TINYPROXY_REVISION" \
    --platform linux/amd64 \
    --manifest "$LOCAL_IMAGE_NAME:$TINYPROXY_VERSION" \
    "$ROOT_DIR"
echo "Built image $LOCAL_IMAGE_NAME:$TINYPROXY_VERSION"
