#!/bin/sh

set -eu

ROOT_DIR="$(dirname "$(realpath "$0")")"

. "$ROOT_DIR/_utils.sh"

mkdir -p "$DIST_DIR"

if [ -z "${TINYPROXY_VERSION:-}" ]; then
    TINYPROXY_VERSION="$(gh release list -R "$TINYPROXY_GIT_URL" --exclude-drafts --exclude-pre-releases -L 1 --json tagName --jq '.[0].tagName')"
    if [ "$?" -ne 0 ] || [ -z "$TINYPROXY_VERSION" ]; then
        echo "Error: Failed to fetch tinyproxy version"
        exit 1
    fi
fi

echo "Version: $TINYPROXY_VERSION"
echo "$TINYPROXY_VERSION" > "$DIST_DIR/version.txt"

if [ -z "${TINYPROXY_REVISION:-}" ]; then
    TINYPROXY_REVISION=$(git ls-remote --tags --refs "$TINYPROXY_GIT_URL" "refs/tags/$TINYPROXY_VERSION" | cut -f1)
    if [ "$?" -ne 0 ] || [ -z "$TINYPROXY_REVISION" ]; then
        echo "Error: Failed to determine revision"
        exit 1
    fi
fi

echo "Revision: $TINYPROXY_REVISION"
echo "$TINYPROXY_REVISION" > "$DIST_DIR/revision.txt"

if [ -z "${NEEDS_RELEASE:-}" ]; then
    set +e
    IMAGE_MANIFEST=$(podman manifest inspect "$IMAGE_NAME:$TINYPROXY_VERSION" 2>&1)
    FOUND_VERSION_EXIT_CODE="$?"
    set -e
    if [ "$FOUND_VERSION_EXIT_CODE" -eq 0 ]; then
        NEEDS_RELEASE="false"
    elif [ "$FOUND_VERSION_EXIT_CODE" -eq 125 ]; then
        NEEDS_RELEASE="true"
    else
        echo "$IMAGE_MANIFEST"
        echo "Error: Failed to fetch image manifest"
        exit 1
    fi
fi

echo "Needs release: $NEEDS_RELEASE"
echo "$NEEDS_RELEASE" > "$DIST_DIR/needs_release.txt"
