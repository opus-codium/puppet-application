# frozen_string_literal: true

require 'fileutils'
require 'mtree'

require_relative 'applications_helper'
require_relative 'artifact'

class Deployment
  include Comparable

  attr_reader :application, :name

  def <=>(other)
    res = application <=> other.application
    return res if res != 0

    name <=> other.name
  end

  def initialize(application, name)
    @application = application
    @name = name
  end

  def self.create(application, name, url)
    deployment = Deployment.new(application, name)
    deployment.deploy(url)
    deployment
  end

  def deploy(url)
    artifact = Artifact.new(url)
    @name ||= artifact.deployment_name

    raise 'Cannot infer deployment name and none specified' if name.nil?

    creating_deployment_directory do
      begin
        raise 'Aborted deployment: before_deploy hook failed' unless run_hook('before_deploy')

        artifact.extract_to(full_path)
        artifact.unlink

        application.setup_persistent_data(self)
        application.link_persistent_data(self)
      rescue => e
        remove
        raise e
      end
    end
    run_hook('after_deploy')
  end

  def active?
    application.current_deployment == self
  end

  def activate
    raise "#{full_path} is not a valid deployment path" unless File.directory?(full_path)
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
    FileUtils.ln_s(full_path, application.current_link_path)
    FileUtils.touch(full_path)
    run_hook('after_activate')
  end

  def created_at
    File.stat(full_path).ctime
  end

  def updated_at
    File.stat(full_path).mtime
  end

  def persistent_data_specifications
    specifications = persistent_data_specifications_load

    specifications = persistent_data_specifications_adjust_for_application(specifications) if specifications

    specifications
  end

  def remove
    raise 'Cannot remove the active deployment' if active?

    FileUtils.rm_rf(full_path)
  end

  private

  def full_path
    File.join(application.path, name)
  end

  def run_hook(name)
    hook = hook_path(name)

    return true unless hook

    pid = Process.fork do
      Process.gid = application.deploy_group if application.deploy_group
      Process.uid = application.deploy_user  if application.deploy_user

      FileUtils.chdir(full_path) do
        exec(hook)
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
    raise "File exist: #{full_path}" if File.directory?(full_path)

    FileUtils.mkdir_p(full_path)

    yield

    FileUtils.chown_R(application.deploy_user, application.deploy_group, full_path)
  end

  def persistent_data_specifications_load
    mtree_file = File.join(full_path, '.mtree')

    return nil unless File.exist?(mtree_file)

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
