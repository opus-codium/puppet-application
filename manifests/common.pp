# @summary Boring implementation details
#
# @api private
class application::common (
  Stdlib::Absolutepath $configuration_root,
  String[1] $configuration_user,
  String[1] $configuration_group,
  Enum['gem', 'puppet_gem'] $gem_dependencies_provider,
) {
  assert_private()

  $configuration_file = "${configuration_root}/metadata.yaml"

  file { $configuration_root:
    ensure => directory,
    owner  => $configuration_user,
    group  => $configuration_group,
    mode   => '0755',
  }

  concat { $configuration_file:
    ensure => present,
    owner  => $configuration_user,
    group  => $configuration_group,
    mode   => '0644',
  }

  ensure_packages(['minitar', 'mtree'], { ensure => installed, provider => $gem_dependencies_provider })
}
