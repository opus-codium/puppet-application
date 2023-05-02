# frozen_string_literal: true

require 'fileutils'

require_relative 'applications_helper'
require_relative 'artifact'

class Deployment
  include Comparable

  attr_reader :application, :name, :path

  def <=>(other)
    res = application <=> other.application
    return res if res != 0

    name <=> other.name
  end

  def initialize(application, name)
    @application = application
    @name = name
    @path = File.join(application.path, name)
  end

  def self.create(application, name, url, headers)
    deployment = Deployment.new(application, name)
    deployment.deploy(url, headers)
    deployment
  end

  def deploy(url, headers)
    artifact = Artifact.new(url, headers)
    @name ||= artifact.deployment_name

    raise 'Cannot infer deployment name and none specified' if name.nil?

    creating_deployment_directory do
      raise 'Aborted deployment: before_deploy hook failed' unless run_hook('before_deploy')

      artifact.extract_to(path)
      artifact.unlink

      application.setup_persistent_data(self)
      application.link_persistent_data(self)
    rescue StandardError => e
      remove
      raise e
    end
    raise 'after_deploy hook failed' unless run_hook('after_deploy')
  end

  def active?
    application.current_deployment == self
  end

  def activate
    raise "#{path} is not a valid deployment path" unless File.directory?(path)
    raise 'Aborted activation: before_activate hook failed' unless run_hook('before_activate')

    # We need to remove the existing symlink otherwise the link is
    # created in the directory pointed to by the existing symlink, so
    # instead of:
    #
    # application
    # |-> current -> /path/to/application/new_deploy
    # |-> previous_deploy
    # `-> new_deploy
    #
    # we have:
    #
    # application
    # |-> current -> /path/to/application/previous_deploy
    # |-> previous_deploy
    # |   `-> new_deploy -> /path/to/application/new_deploy
    # `-> new_deploy

    FileUtils.rm_f(application.current_link_path)
    FileUtils.ln_s(path, application.current_link_path)
    FileUtils.touch(path)
    raise 'after_activate hook failed' unless run_hook('after_activate')
  end

  def updated_at
    File.stat(path).mtime
  end

  def persistent_data_specifications
    specifications = persistent_data_specifications_load

    specifications = persistent_data_specifications_adjust_for_application(specifications) if specifications

    specifications
  end

  def remove
    raise 'Cannot remove the active deployment' if active?

    FileUtils.rm_rf(path)
  end

  private

  def run_hook(name)
    hook = hook_path(name)

    return true unless hook

    pid = Process.fork do
      Process.gid = application.deploy_group if application.deploy_group
      Process.uid = application.deploy_user  if application.deploy_user

      ENV.delete_if { |variable| variable !~ %r{^LC_} }

      ENV['APPLICATION_NAME'] = application.name
      ENV['APPLICATION_PATH'] = application.path
      ENV['ENVIRONMENT'] = application.environment
      ENV['DEPLOYMENT_NAME'] = name
      ENV['DEPLOYMENT_PATH'] = path

      application.user_mapping.each do |user, actual|
        ENV["USER_MAPPING_#{user}"] = actual
      end

      application.group_mapping.each do |user, actual|
        ENV["GROUP_MAPPING_#{user}"] = actual
      end

      FileUtils.chdir(path) do
        Process.exec(hook)
      end
    end

    Process.wait(pid)

    $CHILD_STATUS.success?
  end

  def hook_path(hook_name)
    return nil unless application.kind

    path = File.join(ApplicationsHelper.instance.configuration_root, application.kind, hook_name)

    path if File.executable?(path)
  end

  def creating_deployment_directory
    raise "File exist: #{path}" if File.directory?(path)

    FileUtils.mkdir_p(path)

    # When the application is deployed by an unprivilegied deployment user, we
    # want them to have r/w access to the deployment directory in the
    # before_deploy hook.
    FileUtils.chown(application.deploy_user, application.deploy_group, path)

    yield

    # After extraction by root, files might belong to random users.  We want
    # them to belong to the deployment user.
    #
    # FIXME: Extract files as the deployment user with --no-same-owner and
    # --same-permissions to avoid this step.
    FileUtils.chown_R(application.deploy_user, application.deploy_group, path)
  end

  def persistent_data_specifications_load
    mtree_file = File.join(path, '.mtree')

    return nil unless File.exist?(mtree_file)

    require 'mtree'
    parser = Mtree::Parser.new
    parser.parse_file(mtree_file)
    parser.specifications
  end

  def persistent_data_specifications_adjust_for_application(specifications)
    specifications.each do |specification|
      specification.uname = application.user_mapping.fetch(specification.uname, specification.uname)
      specification.gname = application.group_mapping.fetch(specification.gname, specification.gname)
    end

    specifications
  end
end
