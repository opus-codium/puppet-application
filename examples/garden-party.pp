# lint:ignore:strict_indent
application::kind { 'rails':
  after_deploy_content    => @(SH),
    #!/bin/sh
    export RAILS_ENV=production
    bundle install --deployment
    bundle exec rake assets precompile
    | SH
  before_activate_content => @(SH),
    #!/bin/sh
    export RAILS_ENV=production
    bundle exec rake db:migrate
    | SH
  after_activate_content  => @(SH),
    #!/bin/sh
    touch tmp/restart.txt
    | SH
}
# lint:endignore

file { '/srv/www':
  ensure => directory,
}

application { 'garden-party-prod':
  application => 'garden-party',
  environment => 'production',
  path        => '/srv/www/garden-party-prod',
  kind        => 'rails',
}

application { 'garden-party-dev':
  application  => 'garden-party',
  environment  => 'development',
  path         => '/srv/www/garden-party-dev',
  kind         => 'rails',
  user_mapping => {
    'gardener' => 'wormy',
  },
}

# bolt task run application::deploy application=garden-party environment=production url='https://artifacts.example.com/garden-party/latest.tar.gz' deployment_name=$(date)
