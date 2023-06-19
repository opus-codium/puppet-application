# @summary Declare an application to orchestrate deployments
#
# @param application Name of the application to deploy
# @param environment Environment of the application to deploy
# @param path Path of the application
# @param deploy_user User used to deploy the application
# @param deploy_group Group used to deploy the application
# @param user_mapping User mapping for managing deployment file permissions
# @param group_mapping Group mapping for managing deployment file permissions
# @param kind Kind of the application to deploy
# @param retention_min Minimum number of deployments to keep on disk when pruning
# @param retention_max Maximum number of deployments to keep on disk after deploying a new deployment (enable auto-pruning)
define application (
  String[1] $application,
  String[1] $environment,
  Stdlib::Absolutepath $path,
  Optional[String[1]] $deploy_user          = undef,
  Optional[String[1]] $deploy_group         = undef,
  Hash[String[1], String[1]] $user_mapping  = {},
  Hash[String[1], String[1]] $group_mapping = $user_mapping,
  Optional[String[1]] $kind                 = undef,
  Integer[1] $retention_min                 = 5,
  Optional[Integer[1]] $retention_max       = undef,
) {
  include application::common

  concat::fragment { "application-${name}":
    target  => $application::common::configuration_file,
    content => [
      {
        title         => $title,
        application   => $application,
        path          => $path,
        kind          => $kind,
        environment   => $environment,
        deploy_user   => $deploy_user,
        deploy_group  => $deploy_group,
        user_mapping  => $user_mapping,
        group_mapping => $group_mapping,
        retention_min => $retention_min,
        retention_max => $retention_max,
      },
    ].stdlib::to_yaml.regsubst("\\A---\n", ''),
  }

  file { $path:
    ensure => directory,
    owner  => $deploy_user,
    group  => $deploy_group,
    mode   => '0755',
  }
}
