# frozen_string_literal: true

require_relative 'deployment'

class Application
  CURRENT         = 'current'
  PERSISTENT_DATA = 'persistent-data'

  attr_reader :name, :path, :environment, :deploy_user, :deploy_group, :user_mapping, :group_mapping, :kind

  def initialize(name:, path:, environment: nil, deploy_user: nil, deploy_group: nil, kind: nil, user_mapping: {}, group_mapping: {})
    @name          = name
    @path          = path
    @environment   = environment
    @deploy_user   = deploy_user
    @deploy_group  = deploy_group
    @kind          = kind
    @user_mapping  = user_mapping
    @group_mapping = group_mapping
  end

  def deploy(url, deployment_name)
    deployment = Deployment.create(self, deployment_name, url)

    deployment.activate
  end

  def deployments
    deployments = []

    Dir.glob(File.join(path, '*')).each do |deployment_path|
      deployment_name = File.basename(deployment_path)
      next if [
        CURRENT,
        PERSISTENT_DATA,
      ].include?(deployment_name)

      deployments << Deployment.new(self, deployment_name)
    end

    deployments.sort_by(&:updated_at).map { |deployment| [deployment.name, deployment] }.to_h
  end

  def current_deployment
    deployments[current_deployment_name]
  end

  def current_deployment_name
    File.basename(current_deployment_path)
  rescue Errno::ENOENT
    nil
  end

  def current_deployment_path
    File.realpath(current_link_path)
  end

  def current_link_path
    File.join(path, CURRENT)
  end

  def setup_persistent_data(deployment)
    spec = deployment.persistent_data_specifications

    return unless spec

    spec.enforce(persistent_data_path)
  end

  def link_persistent_data(deployment)
    spec = deployment.persistent_data_specifications

    return unless spec

    spec.leaves!
    spec.symlink_to!(persistent_data_path)

    spec.enforce(deployment.full_path)
  end

  def persistent_data_path
    File.join(path, PERSISTENT_DATA)
  end

  def prune(keep)
    extra_deployments = deployments.values.sort_by(&:updated_at).slice(0...-keep)

    # If there are less than keep deployments, do not attempt to remove the current one.
    extra_deployments.delete(current_deployment)

    extra_deployments.each(&:remove)
  end
end
