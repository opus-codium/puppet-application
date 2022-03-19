# Continuous Delivery (CD) Docker image

Use this as a template to build a CD container for your organization.  This container has a `deploy` user which can use choria / mco as a client of your infrastructure.

| File                       | Description                                                                |
| -------------------------- | -------------------------------------------------------------------------- |
| `client.conf`              | Base configuration file for choria client                                  |
| `Dockerfile-mco`           | Rules to build the CD container                                            |
| `.gitlab-ci.yml`           | GitLab CI configuration to build the CD container and publish it in GitLab |
| `Dockerfile-choria-enroll` | Rules to build a helper container to populate the `ssl` directory          |
| `setup-ssl`                | Script to automate the configuration of the `ssl` directory                |

## Preparing client.conf

The `client.conf` need adjusting to fit your site configuration.  When using SRV records (as recommanded for choria deployment), adjust `plugin.choria.srv_domain` with you site domain name.

## Preparing the ssl directory

A `ssl` directory containing the certificate of the CA of your organization and the certificate + key of a deploy user signed by this CA is required for building the CD container.  The layout of this directory is as follow:

```
ssl
|-> certs
|   |-> ca.pem
|   `-> deploy.mcollective.pem
`-> private_keys
    `-> deploy.mcollective.pem
```

You can either generate these files manualy, or use the `setup-ssl` script to do this automatically.  When using the script, an enrollment container will be created and run.  Connect to your puppet server and sign the certificate using `puppetserver ca sign --certname deploy.mcollective`, and the container will terminate and be removed, but the ssl directory will be ready to use.

## Setup using GitLab

1. Create an new project and copy the files from this directory at the root of it;
2. Adjust the connection settings in `client.conf` (see above);
3. Setup the `ssl` directory and add it to the repository (see above);
4. Commit and push your code so that GitLab CI build the CD container and makes it available.

## Manual Setup

1. Adjust the connection settings in `client.conf` (see above);
2. Setup the `ssl` directory (see above);
3. Build the CI/CD container using `docker build .`.

## Using the CD container

Assuming you setup a GitLab project `image-builder/mco` in a registry named `registry.example.com`, add a deploy step as follow to deploy the *foo* application:

```yaml
deloy:
  stage: deploy
  only:
    - main
  needs:
    - build artifact
  image:
    name: registry.example.com/image-builder/mco
  script: mco tasks run application::deploy --application=foo --environment=production --url="${URL}" --deployment_name="${CI_COMMIT_SHA}" -C profile::foo
```
