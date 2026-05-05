#!/bin/sh

set -eu

if [ $# -lt 2 ]; then
  echo "usage: $0 <dsym-path> <upload-url> [app-bundle-id] [app-version] [app-build]" >&2
  exit 1
fi

DSYM_PATH="$1"
UPLOAD_URL="$2"
APP_BUNDLE_ID="${3:-}"
APP_VERSION="${4:-}"
APP_BUILD="${5:-}"

if [ ! -d "$DSYM_PATH" ]; then
  echo "dSYM path not found: $DSYM_PATH" >&2
  exit 1
fi

UUIDS="$(dwarfdump --uuid "$DSYM_PATH" | awk '{print $2}' | paste -sd "," -)"
ZIP_PATH="$(mktemp /tmp/ltbugly-dsym.XXXXXX.zip)"

/usr/bin/zip -r -q "$ZIP_PATH" "$DSYM_PATH"

/usr/bin/curl \
  --fail \
  --show-error \
  --location \
  -X POST "$UPLOAD_URL" \
  -F "file=@${ZIP_PATH}" \
  -F "uuids=${UUIDS}" \
  -F "bundle_id=${APP_BUNDLE_ID}" \
  -F "version=${APP_VERSION}" \
  -F "build=${APP_BUILD}"

rm -f "$ZIP_PATH"
