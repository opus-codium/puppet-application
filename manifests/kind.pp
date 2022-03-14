# @summary Declare a set of hooks for application deployment
#
# Hooks are run from the deployment directory as the user configured by `deploy_user` in the application.
#
# The following hooks are available:
#
# * before_deploy
# * after_deploy
# * before_activate
# * after_activate
#
# A `before_*` hook returning with a non-zero exit code aborts the operation.
# The exit code of `after_*` hooks is ignored.
#
# The following environment variables are set for each hook invocation:
#
# * `APPLICATION_NAME` - The name of the application (e.g. "acme")
# * `APPLICATION_PATH` - The path of the application (e.g. "/opt/acme")
# * `ENVIRONMENT` - The name of the environment (e.g. "production")
# * `DEPLOYMENT_NAME` - The name of the deployment (e.g. "d3")
# * `DEPLOYMENT_PACH` - The path of the deployment (e.g. "/opt/acme/d3")
# * `USER_MAPPING_*` - User mappings
# * `GROUP_MAPPING_*` - Group mappings
#
# Each hook can be set using the corresponding `*_content` or `*_source` parameter.
#
# @param before_deploy_content
# @param before_deploy_source
# @param after_deploy_content
# @param after_deploy_source
# @param before_activate_content
# @param before_activate_source
# @param after_activate_content
# @param after_activate_source
define application::kind (
  Optional[String[1]] $before_deploy_content   = undef,
  Optional[String[1]] $before_deploy_source    = undef,
  Optional[String[1]] $after_deploy_content    = undef,
  Optional[String[1]] $after_deploy_source     = undef,
  Optional[String[1]] $before_activate_content = undef,
  Optional[String[1]] $before_activate_source  = undef,
  Optional[String[1]] $after_activate_content  = undef,
  Optional[String[1]] $after_activate_source   = undef,
) {
  include application::common

  file { "${application::common::configuration_root}/${name}":
    ensure => directory,
    owner  => $application::common::configuration_user,
    group  => $application::common::configuration_group,
    mode   => '0755',
  }

  $before_deploy_ensure = bool2str($before_deploy_content or $before_deploy_source, 'file', 'absent')

  file { "${application::common::configuration_root}/${name}/before_deploy":
    ensure  => $before_deploy_ensure,
    content => $before_deploy_content,
    source  => $before_deploy_source,
    owner   => $application::common::configuration_user,
    group   => $application::common::configuration_group,
    mode    => '0755',
  }

  $after_deploy_ensure = bool2str($after_deploy_content or $after_deploy_source, 'file', 'absent')

  file { "${application::common::configuration_root}/${name}/after_deploy":
    ensure  => $after_deploy_ensure,
    content => $after_deploy_content,
    source  => $after_deploy_source,
    owner   => $application::common::configuration_user,
    group   => $application::common::configuration_group,
    mode    => '0755',
  }

  $before_activate_ensure = bool2str($before_activate_content or $before_activate_source, 'file', 'absent')

  file { "${application::common::configuration_root}/${name}/before_activate":
    ensure  => $before_activate_ensure,
    content => $before_activate_content,
    source  => $before_activate_source,
    owner   => $application::common::configuration_user,
    group   => $application::common::configuration_group,
    mode    => '0755',
  }

  $after_activate_ensure = bool2str($after_activate_content or $after_activate_source, 'file', 'absent')

  file { "${application::common::configuration_root}/${name}/after_activate":
    ensure  => $after_activate_ensure,
    content => $after_activate_content,
    source  => $after_activate_source,
    owner   => $application::common::configuration_user,
    group   => $application::common::configuration_group,
    mode    => '0755',
  }
}
