# inifmt

Trim and squeeze spaces and empty lines

## Features

- Removes leading and trailing spaces from each line
- Replaces two or more consecutive spaces with one, unless they appear between
  double or single quotes on a single line
- Replaces two or more consecutive empty lines with one
- Aligns comments, which can start with `#` or `;`
- Ignores tabs

## Requirements

`awk` must be installed locally.
