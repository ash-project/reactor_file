# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](Https://conventionalcommits.org) for commit guidelines.

<!-- changelog -->

## [v0.18.3](https://github.com/ash-project/reactor_file/compare/v0.18.2...v0.18.3) (2025-06-10)


### Improvements

* Added usage-rules.md file

## [v0.18.2](https://github.com/ash-project/reactor_file/compare/v0.18.1...v0.18.2) (2025-06-05)




### Improvements:

* As of this commit Reactor is now licensed as MIT. by James Harton

## [v0.18.1](https://harton.dev/james/reactor_file/compare/v0.18.0...v0.18.1) (2025-02-09)




### Bug Fixes:

* `write_file` should work when the file doesn't exist.

* allow middlware to be used in composed reactors without clashing.

## [v0.18.0](https://harton.dev/james/reactor_file/compare/v0.17.0...v0.18.0) (2025-02-02)




### Features:

* Add File open/close and IO operations. (#41)

## [v0.17.0](https://harton.dev/james/reactor_file/compare/v0.16.0...v0.17.0) (2025-02-01)




### Features:

* Add `write_file` DSL step. (#40)

## [v0.16.0](https://harton.dev/james/reactor_file/compare/v0.15.0...v0.16.0) (2025-02-01)




### Features:

* Add `read_file` DSL step. (#38)

## [v0.15.0](https://harton.dev/james/reactor_file/compare/v0.14.0...v0.15.0) (2025-01-30)




### Features:

* Add `touch` step. (#37)

## [v0.14.0](https://harton.dev/james/reactor_file/compare/v0.13.1...v0.14.0) (2025-01-30)




### Features:

* Add the `write_stat` step. (#36)

## [v0.13.1](https://harton.dev/james/reactor_file/compare/v0.13.0...v0.13.1) (2025-01-29)




### Improvements:

* Add support for Reactor 0.11's guards. (#35)

## [v0.13.0](https://harton.dev/james/reactor_file/compare/v0.12.0...v0.13.0) (2025-01-28)
### Breaking Changes:

* Rename revert option on all steps for consistency.



### Features:

* Add `rm` step.

## [v0.12.0](https://harton.dev/james/reactor_file/compare/v0.11.0...v0.12.0) (2025-01-27)




### Features:

* Add `lstat` and `read_link` steps. (#26)

## [v0.11.0](https://harton.dev/james/reactor_file/compare/v0.10.0...v0.11.0) (2025-01-27)




### Features:

* Add `cp_r` step. (#21)

## [v0.10.0](https://harton.dev/james/reactor_file/compare/v0.9.0...v0.10.0) (2025-01-23)




### Features:

* Add `ln` step. (#17)

## [v0.9.0](https://harton.dev/james/reactor_file/compare/v0.8.0...v0.9.0) (2025-01-22)




### Features:

* Add `cp` step. (#10)

## [v0.8.0](https://harton.dev/james/reactor_file/compare/v0.7.0...v0.8.0) (2025-01-17)




### Features:

* Add `chmod` step. (#9)

## [v0.7.0](https://harton.dev/james/reactor_file/compare/v0.6.0...v0.7.0) (2025-01-17)




### Features:

* Add `chown` DSL step. (#8)

## [v0.6.0](https://harton.dev/james/reactor_file/compare/v0.5.0...v0.6.0) (2025-01-17)




### Features:

* Add `chgrp` step. (#7)

## [v0.5.0](https://harton.dev/james/reactor_file/compare/v0.4.2...v0.5.0) (2025-01-17)




### Features:

* Add `stat` step, which returns information about a path. (#5)

## [v0.4.2](https://harton.dev/james/reactor_file/compare/v0.4.1...v0.4.2) (2025-01-17)




### Improvements:

* Rename `file_glob` to just `glob` (#4)

## [v0.4.1](https://harton.dev/james/reactor_file/compare/v0.4.0...v0.4.1) (2025-01-17)




### Improvements:

* Make destructive steps undoable. (#3)

## [v0.4.0](https://harton.dev/james/reactor_file/compare/v0.3.0...v0.4.0) (2025-01-15)




### Features:

* Add `rmdir` DSL step. (#2)

## [v0.3.0](https://harton.dev/james/reactor_file/compare/v0.2.1...v0.3.0) (2025-01-15)




### Features:

* Add `mkdir` and `mkdir_p` DSL entities and step. (#1)

## [v0.2.1](https://harton.dev/james/reactor_file/compare/v0.2.0...v0.2.1) (2025-01-14)




### Improvements:

* fix possible test file clobbering.

## [v0.2.0](https://harton.dev/james/reactor_file/compare/v0.1.0...v0.2.0) (2025-01-14)




### Features:

* Initial version with `file_glob` step.

## [v0.1.0](https://harton.dev/james/reactor_file/compare/v0.1.0...v0.1.0) (2025-01-14)




### Features:

* Initial version with `file_glob` step.
