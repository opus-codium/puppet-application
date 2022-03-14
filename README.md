# application

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Module description](#module-description)
* [Usage](#usage)
	* [Declaring an application](#declaring-an-application)
	* [mtree integration](#mtree-integration)
	* [Hooks](#hooks)

<!-- vim-markdown-toc -->

## Module description

This Puppet module provide tooling for Continuous Delivery (CD) of applications in a Puppet managed environment by leveraging orchestration through [Bolt](https://puppet.com/docs/bolt/latest/bolt.html) or [Choria](https://choria.io/).

## Usage

### Declaring an application

Each application is declared as an `application` resource. They are identified by a unique `title`, an `application` name, an `environment` name and a `path`:

```puppet
application { 'acme':
  application => 'acme',
  environment => 'production',
  path        => '/opt/acme',
}
```

On disc, this will result in this directory hierarchy (assuming 3 deployments are created: `d1`, `d2`, `d3`):

```
/opt/acme/
|-> current@ -> /opt/acme/d3
|-> d1/
|-> d2/
`-> d3/
```

Your profile is likely to declare an `application` resource and additional resources that make it useful and point in the `current` directory:

```puppet
class profile::acme {
  application { 'acme':
    application => 'acme',
    environment => 'production',
    path        => '/opt/acme',
  }

  file { '/usr/local/bin/acme-runner':
    ensure => link,
    target => '/opt/acme/current/bin/acme-runner',
  }

  apache::vhost { 'acme.example.com':
    docroot => '/opt/acme/current/public',
  }
}
```

### mtree integration

Sometimes, some data must persist through deployments (e.g. uploaded files, logs).  The application module install the [mtree](https://rubygems.org/gems/mtree) gem to manage symbolic links in the deployments directory and have them point to a `persistent-data` directory if a `.mtree` file is found at the root of a deployment.

Assuming a `.mtree` file is added at the root of the previous project containing:

```
/set type=dir uname=deploy gname=deploy mode=0755
.
	db uname=user
		production.sqlite3 type=file uname=user mode=0640
		..
	..
	config
		database.yml type=file gname=user mode=0640
		..
	..
	log
		production.log type=file gname=user mode=0660
		..
	..
	tmp uname=user gname=user
	..
..
```

On the next deployment `d4`, the described hierarchy tree will be created in the `persistent-data` directory, and all files corresponding to leaves of this tree in the deployment will be removed and replaced by symbolic-links to the corresponding persistent-data file:

```
/opt/acme/
|-> current@ -> /opt/acme/d3
|-> d1/
|-> d2/
|-> d3/
|-> d4/
|   |-> db/
|   |   `-> production.sqlite3@ -> /opt/acme/persistent-data/db/production.sqlite3
|   |-> config/
|   |   `-> database.yml@ -> /opt/acme/persistent-data/config/database.yml
|   |-> log/
|   |   `-> production.log@ -> /opt/acme/persistent-data/log/production.log
|   `-> tmp@ -> /opt/acme/persistent-data/tmp/
`-> persistent-data/
    |-> db/
    |   `-> production.sqlite3
    |-> config/
    |   `-> database.yml
    |-> log/
    |   `-> production.log
    `-> tmp/
```

### Hooks

Actions that must be performed before / after deployment and activation can be registered in hooks that can be shared by multiple applications.  Before hooks can abort an operation by exiting with a non-null exit code.

As an example, one may want to use the following to deploy [Ruby on Rails](https://rubyonrails.org/) applications:

```puppet
application::kind { 'rails':
  before_activate => @(SH),
    #!/bin/sh

    set -e

    RAILS_ENV=$ENVIRONMENT bundle exec rails db:migrate
    | SH
  after_activate  => @(SH),
    #!/bin/sh
    touch tmp/restart.txt
    | SH
}
```
