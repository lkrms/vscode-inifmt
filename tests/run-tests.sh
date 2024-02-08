#!/usr/bin/env bash

set -euo pipefail

# die [<message>]
function die() {
    local s=$?
    printf '%s: %s\n' "${0##*/}" "${1-command failed}" >&2
    ((!s)) && exit 1 || exit "$s"
}

# run <command> [<argument>...]
function run() {
    printf ' -> running:%s\n' "$(printf ' %q' "$@")" >&2
    "$@"
}

[[ ${BASH_SOURCE[0]} -ef tests/run-tests.sh ]] ||
    die "must run from root of package folder"

temp=$(mktemp)
trap 'rm -f "$temp"' EXIT

tests=0
passed=0
failed=0
added=0
errors=()
for file_in in tests/fixtures/in/*; do
    file=${file_in##*/}
    file_out=${file_in/in/out}
    if [[ ! -f $file_out ]]; then
        printf '==> adding: %s\n' "$file" >&2
        run awk -f scripts/inifmt.awk "$file_in" >"$file_out"
        ((++added))
    else
        printf '==> testing: %s\n' "$file" >&2
        run awk -f scripts/inifmt.awk "$file_in" >"$temp"
        if diff -u --label expected --label actual --color=auto "$file_out" "$temp"; then
            ((++passed))
        else
            errors[${#errors[@]}]=$file
            ((++failed))
        fi
        ((++tests))
    fi
    printf '\n' >&2
done

summary=(Tests "$tests")
((!passed)) || summary+=(Passed "$passed")
((!failed)) || summary+=(Failed "$failed")
((!added)) || summary+=(Added "$added")

{
    if ((!failed)); then
        printf 'OK\n'
    else
        printf 'ERRORS!\n'
        printf -- '- %s\n' "${errors[@]}"
        printf '\n'
    fi
    printf '%s: %d, ' "${summary[@]}" | sed -E 's/, $/\n/'
} >&2

((!failed))
