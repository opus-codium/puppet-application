# lint:ignore:strict_indent
application::kind { 'rails':
  after_deploy_content    => @(SH),
    #!/bin/sh
    export RAILS_ENV=production
    bundle install --deployment
    bundle exec rake assets precompile
    bundle exec rake db:migrate
    | SH
  before_activate_content => @(SH),
    #!/bin/sh
    ./scripts/lb-manage detach drain
    | SH
  after_activate_content  => @(SH),
    #!/bin/sh
    ./scripts/lb-manage attach
    | SH
}
# lint:endignore

application { '/srv/www/garden-party-prod':
  application => 'garden-party',
  environment => 'production',
  kind        => 'rails',
}

application { '/srv/www/garden-party-dev':
  application  => 'garden-party',
  environment  => 'development',
  kind         => 'rails',
  user_mapping => {
    'gardener' => 'wormy',
  },
}

# bolt task run application::deploy application=garden-party environment=production url='https://artifacts.example.com/garden-party/latest.tar.gz' deployment_name=$(date)
