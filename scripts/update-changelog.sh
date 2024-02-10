#!/usr/bin/env bash

set -euo pipefail

die() {
    printf '%s: %s\n' "$0" "$1" >&2
    exit 1
}

[[ ${BASH_SOURCE[0]} -ef scripts/update-changelog.sh ]] ||
    die "must run from root of package folder"

tools/php-changelog \
    --output CHANGELOG.md \
    lkrms/vscode-inifmt
