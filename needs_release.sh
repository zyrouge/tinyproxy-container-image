#!/bin/sh

set -eu

GIT_URL="https://github.com/zyrouge/tinyproxy-container-image.git"
TINYPROXY_GIT_URL="https://github.com/tinyproxy/tinyproxy"
IMAGE_NAME="ghcr.io/zyrouge/tinyproxy"

if [ -z "${TINYPROXY_VERSION:-}" ]; then
    TINYPROXY_VERSION="$(gh release list -R "$TINYPROXY_GIT_URL" --exclude-drafts --exclude-pre-releases -L 1 --json tagName --jq '.[0].tagName')"
    if [ "$?" -ne 0 ] || [ -z "$TINYPROXY_VERSION" ]; then
        exit 1
    fi
fi

FOUND_VERSION=$(docker manifest inspect "$IMAGE_NAME:$TINYPROXY_VERSION" > /dev/null 2>&1 && echo "found" || echo "")
if [ "$FOUND_VERSION" = "found" ]; then
    exit 1
fi

echo "$TINYPROXY_VERSION"
