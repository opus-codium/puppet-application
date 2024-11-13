# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v4.1.0](https://github.com/opus-codium/puppet-application/tree/v4.1.0) (2024-11-13)

[Full Changelog](https://github.com/opus-codium/puppet-application/compare/v4.0.1...v4.1.0)

**Implemented enhancements:**

- Allow `file://` URI scheme [\#53](https://github.com/opus-codium/puppet-application/pull/53) ([smortex](https://github.com/smortex))
- Add support for FreeBSD 14 [\#50](https://github.com/opus-codium/puppet-application/pull/50) ([smortex](https://github.com/smortex))
- Add support for Debian 12 [\#49](https://github.com/opus-codium/puppet-application/pull/49) ([smortex](https://github.com/smortex))

**Fixed bugs:**

- Use an AIO-agnostic path to Ruby for tasks [\#57](https://github.com/opus-codium/puppet-application/pull/57) ([smortex](https://github.com/smortex))
- Fix deployment path inference [\#56](https://github.com/opus-codium/puppet-application/pull/56) ([smortex](https://github.com/smortex))
- Fix read\_deployment\_name on FreeBSD [\#52](https://github.com/opus-codium/puppet-application/pull/52) ([smortex](https://github.com/smortex))

**Closed issues:**

- Deploying without deployment name is currently broken [\#55](https://github.com/opus-codium/puppet-application/issues/55)
- Allow deploying from a local file \(e.g. `file:///path/to/file` or `/path/to/file`\) [\#54](https://github.com/opus-codium/puppet-application/issues/54)

## [v4.0.1](https://github.com/opus-codium/puppet-application/tree/v4.0.1) (2024-01-09)

[Full Changelog](https://github.com/opus-codium/puppet-application/compare/v4.0.0...v4.0.1)

**Fixed bugs:**

- Fix task execution with Ruby 3.2 [\#45](https://github.com/opus-codium/puppet-application/pull/45) ([smortex](https://github.com/smortex))

## [v4.0.0](https://github.com/opus-codium/puppet-application/tree/v4.0.0) (2023-07-05)

[Full Changelog](https://github.com/opus-codium/puppet-application/compare/v3.0.0...v4.0.0)

**Breaking changes:**

- Require puppetlabs/stdlib 9.x [\#39](https://github.com/opus-codium/puppet-application/pull/39) ([smortex](https://github.com/smortex))

**Implemented enhancements:**

- Add support for Puppet 8 [\#38](https://github.com/opus-codium/puppet-application/pull/38) ([smortex](https://github.com/smortex))
- Relax dependencies version requirements [\#37](https://github.com/opus-codium/puppet-application/pull/37) ([smortex](https://github.com/smortex))

## [v3.0.0](https://github.com/opus-codium/puppet-application/tree/v3.0.0) (2022-11-14)

[Full Changelog](https://github.com/opus-codium/puppet-application/compare/v2.0.0...v3.0.0)

**Breaking changes:**

- Raise an exception when an after\_deploy/after\_activate hook fail [\#34](https://github.com/opus-codium/puppet-application/pull/34) ([smortex](https://github.com/smortex))

## [v2.0.0](https://github.com/opus-codium/puppet-application/tree/v2.0.0) (2022-10-20)

[Full Changelog](https://github.com/opus-codium/puppet-application/compare/v1.2.0...v2.0.0)

**Breaking changes:**

- Raise an error if no matching application is found [\#30](https://github.com/opus-codium/puppet-application/pull/30) ([smortex](https://github.com/smortex))

**Implemented enhancements:**

- Add support for extracting more archive formats [\#31](https://github.com/opus-codium/puppet-application/pull/31) ([smortex](https://github.com/smortex))

**Fixed bugs:**

- Fix ownership of deployment before before\_deploy hook [\#32](https://github.com/opus-codium/puppet-application/pull/32) ([smortex](https://github.com/smortex))
- Fix listing applications when requiements are missing [\#29](https://github.com/opus-codium/puppet-application/pull/29) ([smortex](https://github.com/smortex))

## [v1.2.0](https://github.com/opus-codium/puppet-application/tree/v1.2.0) (2022-06-16)

[Full Changelog](https://github.com/opus-codium/puppet-application/compare/v1.1.0...v1.2.0)

**Implemented enhancements:**

- Allow passing custom headers to fetch artifacts [\#27](https://github.com/opus-codium/puppet-application/pull/27) ([smortex](https://github.com/smortex))

## [v1.1.0](https://github.com/opus-codium/puppet-application/tree/v1.1.0) (2022-06-06)

[Full Changelog](https://github.com/opus-codium/puppet-application/compare/v1.0.1...v1.1.0)

**Implemented enhancements:**

- Rely on Puppet 7.16 ablitiy to use the system store [\#25](https://github.com/opus-codium/puppet-application/pull/25) ([smortex](https://github.com/smortex))
- Improve CD Docker integration [\#23](https://github.com/opus-codium/puppet-application/pull/23) ([smortex](https://github.com/smortex))

## [v1.0.1](https://github.com/opus-codium/puppet-application/tree/v1.0.1) (2022-03-17)

[Full Changelog](https://github.com/opus-codium/puppet-application/compare/v1.0.0...v1.0.1)

**Fixed bugs:**

- Fix module metadata [\#22](https://github.com/opus-codium/puppet-application/pull/22) ([smortex](https://github.com/smortex))

## [v1.0.0](https://github.com/opus-codium/puppet-application/tree/v1.0.0) (2022-03-17)

[Full Changelog](https://github.com/opus-codium/puppet-application/compare/ba003831f3735496f08f3eed97e8c03cad8dff1e...v1.0.0)

**Breaking changes:**

- Adjust hooks environment variables [\#16](https://github.com/opus-codium/puppet-application/pull/16) ([smortex](https://github.com/smortex))

**Implemented enhancements:**

- Add a task to list applications and deployments [\#13](https://github.com/opus-codium/puppet-application/pull/13) ([smortex](https://github.com/smortex))

**Merged pull requests:**

- Release 1.0.0 [\#21](https://github.com/opus-codium/puppet-application/pull/21) ([smortex](https://github.com/smortex))
- Allow configuring the number of deployments to keep [\#20](https://github.com/opus-codium/puppet-application/pull/20) ([smortex](https://github.com/smortex))
- Add tooling to build CD docker images [\#19](https://github.com/opus-codium/puppet-application/pull/19) ([smortex](https://github.com/smortex))
- Allow custom titles [\#18](https://github.com/opus-codium/puppet-application/pull/18) ([smortex](https://github.com/smortex))
- Add some documentation [\#17](https://github.com/opus-codium/puppet-application/pull/17) ([smortex](https://github.com/smortex))
- Rename Deployment\#full\_path to Deployment\#path [\#15](https://github.com/opus-codium/puppet-application/pull/15) ([smortex](https://github.com/smortex))
- Make $path a parameter of application [\#14](https://github.com/opus-codium/puppet-application/pull/14) ([smortex](https://github.com/smortex))
- Drop created\_at [\#12](https://github.com/opus-codium/puppet-application/pull/12) ([smortex](https://github.com/smortex))
- Populate environment variables [\#11](https://github.com/opus-codium/puppet-application/pull/11) ([smortex](https://github.com/smortex))
- Fix deployment owner [\#10](https://github.com/opus-codium/puppet-application/pull/10) ([smortex](https://github.com/smortex))
- Add minitar as a gem dependency [\#9](https://github.com/opus-codium/puppet-application/pull/9) ([smortex](https://github.com/smortex))
- Allow downloading using system CA and Puppet PKI [\#8](https://github.com/opus-codium/puppet-application/pull/8) ([smortex](https://github.com/smortex))
- Implement mtree substitutions [\#7](https://github.com/opus-codium/puppet-application/pull/7) ([smortex](https://github.com/smortex))
- Infer deployment name from artifact [\#6](https://github.com/opus-codium/puppet-application/pull/6) ([smortex](https://github.com/smortex))
- Add a task to prune old deployments [\#5](https://github.com/opus-codium/puppet-application/pull/5) ([smortex](https://github.com/smortex))
- Add support for non tar-bomb artifacts [\#4](https://github.com/opus-codium/puppet-application/pull/4) ([smortex](https://github.com/smortex))
- Download artifact using Puppet http client [\#3](https://github.com/opus-codium/puppet-application/pull/3) ([smortex](https://github.com/smortex))
- Run the configured hooks on deployment [\#2](https://github.com/opus-codium/puppet-application/pull/2) ([smortex](https://github.com/smortex))
- Add a task to remove a specified deployment [\#1](https://github.com/opus-codium/puppet-application/pull/1) ([smortex](https://github.com/smortex))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
