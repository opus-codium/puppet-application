# frozen_string_literal: true

require 'tempfile'
require 'puppet'

class Artifact
  def initialize(url = nil)
    @tmp_file = Tempfile.open('archive')
    @tmp_file.close
    FileUtils.chmod(0o600, @tmp_file.path)

    download(url) if url
  end

  def download(url)
    Puppet::Util::Execution.execute %(curl --cert "#{hostcert}" --key "#{hostprivkey}" --output #{@tmp_file.path} --fail #{url}),
                                    failonfail: true,
                                    combine: true
  end

  def extract_to(path)
    return if File.empty?(@tmp_file.path)

    Puppet::Util::Execution.execute %(/bin/tar zxf #{@tmp_file.path} -C #{path}),
                                    failonfail: true,
                                    combine: true
  end

  def unlink
    @tmp_file.unlink
  end

  private

  def puppet_setting(setting)
    unless Puppet.settings.app_defaults_initialized?
      Puppet.settings.preferred_run_mode = :agent

      Puppet.settings.initialize_global_settings([])
      Puppet.settings.initialize_app_defaults(Puppet::Settings.app_defaults_for_run_mode(Puppet.run_mode))
      Puppet.push_context(Puppet.base_context(Puppet.settings))
    end

    Puppet.settings[setting]
  end

  def hostcert
    puppet_setting(:hostcert)
  end

  def hostprivkey
    puppet_setting(:hostprivkey)
  end
end
