#!/bin/sh

set -eu

GIT_URL="https://github.com/zyrouge/tinyproxy-container-image.git"
TINYPROXY_GIT_URL="https://github.com/tinyproxy/tinyproxy"

if [ -z "${TINYPROXY_VERSION:-}" ]; then
    TINYPROXY_VERSION="$(gh release list -R "$TINYPROXY_GIT_URL" --exclude-drafts --exclude-pre-releases -L 1 --json tagName --jq '.[0].tagName')"
    if [ "$?" -ne 0 ] || [ -z "$TINYPROXY_VERSION" ]; then
        exit 1
    fi
fi

FOUND_VERSION=$(gh release view -R "$GIT_URL" "$TINYPROXY_VERSION" --json tagName --jq '.[0].tagName' 2>&1 || echo "")
if [ "$FOUND_VERSION" != "release not found" ]; then
    exit 1
fi

echo "$TINYPROXY_VERSION"
