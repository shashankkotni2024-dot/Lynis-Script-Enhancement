#!/bin/sh
set -eu

usage() {
    echo "Usage: sudo ./install.sh 1|2"
    echo "  1  Install Enhancement 1 (module checks only)"
    echo "  2  Install Enhancement 2 (module checks + media detection + risk)"
}

if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root, for example: sudo ./install.sh 2" >&2
    exit 1
fi

case "${1:-}" in
    1) SOURCE="scripts/enhancement1/tests_custom" ;;
    2) SOURCE="scripts/enhancement2/tests_custom" ;;
    *) usage >&2; exit 2 ;;
esac

if [ ! -f "$SOURCE" ]; then
    echo "Cannot find source file: $SOURCE" >&2
    echo "Run this script from the extracted project directory." >&2
    exit 1
fi

INCLUDE_DIR="/usr/share/lynis/include"
TARGET="$INCLUDE_DIR/tests_custom"
if [ ! -d "$INCLUDE_DIR" ]; then
    echo "Lynis include directory not found: $INCLUDE_DIR" >&2
    exit 1
fi

if [ -f "$TARGET" ]; then
    BACKUP="$TARGET.backup.$(date +%Y%m%d%H%M%S)"
    cp -p "$TARGET" "$BACKUP"
    echo "Existing custom tests backed up to: $BACKUP"
fi

install -o root -g root -m 0640 "$SOURCE" "$TARGET"
echo "Installed Enhancement ${1} to $TARGET"
echo "Run: sudo lynis audit system --tests-from-group \"usb storage\" --quick --skip-plugins"
