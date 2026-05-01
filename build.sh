#!/bin/sh

set -e

TINYPROXY_GIT_URL="https://github.com/tinyproxy/tinyproxy"

if [ -z "${TINYPROXY_VERSION:-}" ]; then
    TINYPROXY_VERSION=$(gh release list -R "$TINYPROXY_GIT_URL" --exclude-drafts --exclude-pre-releases -L 1 --json tagName | jq -r '.[0].tagName')
    if [ "$?" -ne 0 ] || [ -z "$TINYPROXY_VERSION" ]; then
        exit 1
    fi
fi

if [ -z "${TINYPROXY_REVISION:-}" ]; then
    TINYPROXY_REVISION=$(git ls-remote --tags --refs "$TINYPROXY_GIT_URL" "refs/tags/$TINYPROXY_VERSION" | cut -f1)
    if [ "$?" -ne 0 ] || [ -z "$TINYPROXY_REVISION" ]; then
        exit 1
    fi
fi

CREATED=$(date -u +"%Y-%m-%dT%H:%M:%S%z")

podman build \
    --build-arg CREATED="$CREATED" \
    --build-arg TINYPROXY_VERSION="$TINYPROXY_VERSION" \
    --build-arg TINYPROXY_REVISION="$TINYPROXY_REVISION" \
    -t "tinyproxy:$TINYPROXY_VERSION" .
