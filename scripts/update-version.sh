#!/usr/bin/env bash

# user.name and user.email must be configured before running this script, e.g.:
#
#     git config user.name "github-actions[bot]"
#     git config user.email "41898282+github-actions[bot]@users.noreply.github.com"

set -euo pipefail

die() {
    printf '%s: %s\n' "$0" "$1" >&2
    exit 1
}

[[ ${BASH_SOURCE[0]} -ef scripts/update-version.sh ]] ||
    die "must run from root of package folder"

[[ -n ${1-} ]] ||
    die "package version required"

version=${1#v}
tag=v$version
clean=1

! git status --porcelain | cut -c4- | grep -Fxv CHANGELOG.md >/dev/null ||
    clean=0

temp=$(mktemp) &&
    trap 'rm -f "$temp"' EXIT ||
    die "error creating temporary file"

jq --arg version "$version" '.version = $version' package.json >"$temp" &&
    { diff -q package.json "$temp" >/dev/null ||
        cp "$temp" package.json; } ||
    die "error updating package.json"

scripts/update-changelog.sh ||
    die "error updating CHANGELOG.md"

((clean)) ||
    die "not committing changes because working tree was not clean"

last_tag=$(git describe --abbrev=0 --match "v[0-9]*") &&
    current=$(git describe --match "v[0-9]*") ||
    die "error checking most recent tag"

git add package.json CHANGELOG.md &&
    git commit -m "Release $tag" &&
    git tag -m "Release $tag" "$tag" &&
    git -c push.default=upstream push --follow-tags ||
    die "error committing changes"

# If there have been other commits since the last version tag, return 2 to
# indicate that a release should not be published automatically
if [[ $last_tag != "$current" ]]; then
    exit 2
fi
