#!/bin/sh

set -e

TINYPROXY_GIT_URL="https://github.com/tinyproxy/tinyproxy"
LOCAL_IMAGE_NAME="localhost/tinyproxy"

if [ -z "${TINYPROXY_VERSION:-}" ]; then
    TINYPROXY_VERSION=$(gh release list -R "$TINYPROXY_GIT_URL" --exclude-drafts --exclude-pre-releases -L 1 --json tagName | jq -r '.[0].tagName')
    if [ "$?" -ne 0 ] || [ -z "$TINYPROXY_VERSION" ]; then
        echo "Failed to get determine version"
        exit 1
    fi
fi

if [ -z "${TINYPROXY_REVISION:-}" ]; then
    TINYPROXY_REVISION=$(git ls-remote --tags --refs "$TINYPROXY_GIT_URL" "refs/tags/$TINYPROXY_VERSION" | cut -f1)
    if [ "$?" -ne 0 ] || [ -z "$TINYPROXY_REVISION" ]; then
        echo "Failed to determine revision"
        exit 1
    fi
fi

CREATED=$(date -u +"%Y-%m-%dT%H:%M:%S%z")

podman manifest rm "$LOCAL_IMAGE_NAME:$TINYPROXY_VERSION" > /dev/null 2>&1 || true

podman manifest create "$LOCAL_IMAGE_NAME:$TINYPROXY_VERSION"

podman build \
    --build-arg CREATED="$CREATED" \
    --build-arg TINYPROXY_VERSION="$TINYPROXY_VERSION" \
    --build-arg TINYPROXY_REVISION="$TINYPROXY_REVISION" \
    --platform linux/amd64 \
    --manifest "$LOCAL_IMAGE_NAME:$TINYPROXY_VERSION" .
