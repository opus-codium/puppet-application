# @summary Declane an application to orchestrate deployments
#
# @param application Name of the application to deploy
# @param environment Environment of the application to deploy
# @param deploy_user User used to deploy the application
# @param deploy_group Group used to deploy the application
# @param user_mapping User mapping for managing deployment file permissions
# @param group_mapping Group mapping for managing deployment file permissions
# @param kind Kind of the application to deploy
define application (
  String[1] $application,
  String[1] $environment,
  Optional[String[1]] $deploy_user          = undef,
  Optional[String[1]] $deploy_group         = undef,
  Hash[String[1], String[1]] $user_mapping  = {},
  Hash[String[1], String[1]] $group_mapping = $user_mapping,
  Optional[String[1]] $kind                 = undef,
) {
  include application::common

  concat::fragment { "application-${name}":
    target  => $application::common::configuration_file,
    content => [
      {
        application   => $application,
        path          => $name,
        kind          => $kind,
        environment   => $environment,
        deploy_user   => $deploy_user,
        deploy_group  => $deploy_group,
        user_mapping  => $user_mapping,
        group_mapping => $group_mapping,
      },
    ].to_yaml.regsubst("\\A---\n", ''),
  }
}
