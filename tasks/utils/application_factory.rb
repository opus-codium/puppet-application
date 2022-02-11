# frozen_string_literal: true

require 'open3'
require 'yaml'

require_relative 'application'

class ApplicationFactory
  def self.find(application, environment)
    config_entries_for(application, environment).map do |spec|
      spec.keys.each do |k|
        spec[k.to_sym] = spec.delete(k)
      end
      spec[:name] = spec.delete(:application)
      Application.new(spec)
    end
  end

  def self.config_entries_for(application, environment)
    load_config.filter do |spec|
      spec['application'] == application &&
        spec['environment'] == environment
    end
  end

  def self.load_config
    stdout, _stderr, _status = Open3.capture3('facter', 'osfamily')

    configuration_filename = case stdout.strip
                             when 'FreeBSD' then '/usr/local/etc/applications/metadata.yaml'
                             else
                               '/etc/applications/metadata.yaml'
                             end

    YAML.safe_load(File.read(configuration_filename))
  end

  private_class_method :config_entries_for, :load_config
end
