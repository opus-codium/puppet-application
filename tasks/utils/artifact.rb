# frozen_string_literal: true

require 'puppet'
require 'tempfile'

class Artifact
  attr_reader :deployment_name

  def initialize(url = nil, headers = {})
    @tmp_file = Tempfile.open('archive')
    @tmp_file.close
    FileUtils.chmod(0o600, @tmp_file.path)

    return unless url

    download(url, headers)
    @deployment_name = read_deployment_name
  end

  def download(url, headers)
    initialize_puppet
    client = Puppet.runtime[:http]
    ssl_provider = Puppet::SSL::SSLProvider.new
    client.get(URI(url), headers: headers, options: { ssl_context: ssl_provider.load_context(revocation: false, include_system_store: true) }) do |response|
      raise 'Failed to download artifact' unless response.success?

      File.open(@tmp_file.path, 'w') do |f|
        response.read_body do |data|
          f.write(data)
        end
      end
    end
  end

  def extract_to(path)
    return if File.empty?(@tmp_file.path)

    Puppet::Util::Execution.execute %(tar zxf #{@tmp_file.path} #{tar_strip_components} -C #{path}),
                                    failonfail: true,
                                    combine: true
  end

  def unlink
    @tmp_file.unlink
  end

  private

  def initialize_puppet
    return if Puppet.settings.app_defaults_initialized?

    Puppet.settings.preferred_run_mode = :agent

    Puppet.settings.initialize_global_settings([])
    Puppet.settings.initialize_app_defaults(Puppet::Settings.app_defaults_for_run_mode(Puppet.run_mode))
    Puppet.push_context(Puppet.base_context(Puppet.settings))
  end

  def read_deployment_name
    res = nil

    require 'minitar'
    Zlib::GzipReader.open(@tmp_file.path) do |io|
      Minitar.open(io) do |tar|
        tar.each_entry do |entry|
          next unless entry.file?
          if res.nil?
            res, rest = entry.full_name.split('/', 2)
            unless rest
              res = nil
              break
            end
          else
            unless entry.full_name.start_with?(res + '/')
              res = nil
              break
            end
          end
        end
      end
    end

    res
  end

  def tar_strip_components
    '--strip-components=1' if deployment_name
  end
end
