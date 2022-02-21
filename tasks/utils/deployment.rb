# frozen_string_literal: true

require 'fileutils'
require 'mtree'

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

  def download_and_extract(url)
    create_deployment_directory
    artifact = Artifact.new(url)
    artifact.extract_to(full_path)
    artifact.unlink
  end

  def active?
    application.current_deployment == self
  end

  def activate
    raise "#{full_path} is not a valid deployment path" unless File.directory?(full_path)

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

  def create_deployment_directory
    raise "File exist: #{full_path}" if File.directory?(full_path)

    FileUtils.mkdir_p(full_path)
    FileUtils.chown(application.deploy_user, application.deploy_group, full_path)
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
      specification.uname = application.user  if specification.uname == 'user'
      specification.gname = application.group if specification.gname == 'user'
    end

    specifications
  end
end
