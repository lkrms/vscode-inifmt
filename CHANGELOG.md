# Changelog

Notable changes to this extension are documented in this file.

It is generated from the GitHub release notes of the project by [salient/changelog][].

The format is based on [Keep a Changelog][].

[salient/changelog]: https://github.com/salient-labs/php-changelog
[Keep a Changelog]: https://keepachangelog.com/en/1.1.0/

## [v0.1.5] - 2022-09-06

### Security

- Update dependencies to mitigate vulnerabilities in `minimist` and `nanoid` reported by dependabot

## [v0.1.4] - 2022-04-29

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

## [v0.1.3] - 2022-01-01

### Added

- Add icon for Visual Studio Marketplace

## [v0.1.2] - 2021-12-31

### Changed

- Ignore escaped characters everywhere, not just between quote marks

### Fixed

- Fix removal of trailing quotes from lines where escaped quotes are not enclosed by unescaped ones, e.g. this Git filter command:

  ```gitconfig
  smudge = jq -S --indent 4 --arg shfmt \"$(type -P shfmt)\" '.+={\"shellformat.path\":$shfmt}'
  ```

## [v0.1.1] - 2021-12-07

### Fixed

- Fix bugs related to quoted text

## [v0.1.0] - 2021-12-07

### Added

- Initial release

[v0.1.5]: https://github.com/lkrms/vscode-inifmt/compare/v0.1.4...v0.1.5
[v0.1.4]: https://github.com/lkrms/vscode-inifmt/compare/v0.1.3...v0.1.4
[v0.1.3]: https://github.com/lkrms/vscode-inifmt/compare/v0.1.2...v0.1.3
[v0.1.2]: https://github.com/lkrms/vscode-inifmt/compare/v0.1.1...v0.1.2
[v0.1.1]: https://github.com/lkrms/vscode-inifmt/compare/v0.1.0...v0.1.1
[v0.1.0]: https://github.com/lkrms/vscode-inifmt/releases/tag/v0.1.0
