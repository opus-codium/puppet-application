# frozen_string_literal: true

require 'open3'
require 'yaml'

require_relative 'application'
require_relative 'applications_helper'

class ApplicationFactory
  def self.all
    find(nil, nil)
  end

  def self.find(application, environment)
    res = configuration_metadata_for(application, environment).map do |spec|
      Application.new(spec)
    end

    raise "No match for application #{application} in environment #{environment}" if res.empty?

    res
  end

  def self.configuration_metadata_for(application, environment)
    res = load_configuration_metadata.filter do |spec|
      match = true

      match = false if application && spec['application'] != application
      match = false if environment && spec['environment'] != environment

      match
    end

    res.map do |spec|
      spec.transform_keys!(&:to_sym)
      spec[:name] = spec.delete(:application)
      spec
    end
  end

  def self.load_configuration_metadata
    YAML.safe_load(File.read(ApplicationsHelper.instance.configuration_metadata))
  rescue Errno::ENOENT
    {}
  end

  private_class_method :configuration_metadata_for, :load_configuration_metadata
end
