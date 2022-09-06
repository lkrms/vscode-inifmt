# Changelog

## [0.1.0] - 2021-12-07
- Initial release

## [0.1.1] - 2021-12-07
### Fixed
- Fix bugs related to quoted text

## [0.1.2] - 2021-12-31
### Changed
- Ignore escaped characters everywhere, not just between quote marks

### Fixed
- Fix removal of trailing quotes from lines where escaped quotes are not
  enclosed by unescaped ones, e.g. this Git filter command:

  ```gitconfig
    smudge = jq -S --indent 4 --arg shfmt \"$(type -P shfmt)\" '.+={\"shellformat.path\":$shfmt}'
  ```

## [0.1.3] - 2022-01-01
### Added
- Add icon for Visual Studio Marketplace

## [0.1.4] - 2022-04-29
### Fixed
- Fix tabulated comment alignment issue where this:

  ```
      # This line has leading tabs
      So does this text
  ```

  became this:

  ```
                        # This line has leading tabs
      So does this text
  ```

## [0.1.5] - 2022-09-06
### Security
- Update dependencies to mitigate vulnerabilities in `minimist` and `nanoid`
  reported by dependabot

