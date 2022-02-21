# frozen_string_literal: true

require 'singleton'

class ApplicationsHelper
  include Singleton

  def configuration_metadata
    File.join(configuration_root, 'metadata.yaml')
  end

  def configuration_root
    return @configuration_root if @configuration_root

    stdout, _stderr, _status = Open3.capture3('facter', 'osfamily')

    @configuration_root = case stdout.strip
                          when 'FreeBSD' then '/usr/local/etc/applications'
                          else
                            '/etc/applications'
                          end
  end
end
