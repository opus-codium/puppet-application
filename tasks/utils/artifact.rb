# frozen_string_literal: true

require 'minitar'
require 'puppet'
require 'tempfile'

class Artifact
  attr_reader :deployment_name

  def initialize(url = nil)
    @tmp_file = Tempfile.open('archive')
    @tmp_file.close
    FileUtils.chmod(0o600, @tmp_file.path)

    return unless url

    download(url)
    @deployment_name = read_deployment_name
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

    Puppet::Util::Execution.execute %(tar zxf #{@tmp_file.path} #{tar_strip_components} -C #{path}),
                                    failonfail: true,
                                    combine: true
  end

  def unlink
    @tmp_file.unlink
  end

  private

  def read_deployment_name
    res = nil

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
