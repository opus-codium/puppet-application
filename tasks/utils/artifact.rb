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
    client = Puppet.runtime[:http]
    client.get(URI(url), options: { include_system_store: true }) do |response|
      if response.success?
        File.open(@tmp_file.path, 'w') do |f|
          response.read_body do |data|
            f.write(data)
          end
        end
      end
    end
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
end
