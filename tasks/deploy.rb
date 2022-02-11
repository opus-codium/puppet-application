#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'open3'

require_relative '../../ruby_task_helper/files/task_helper'

require_relative 'utils/application_factory'

class ApplicationDeployTask < TaskHelper
  def task(application:, environment:, url:, deployment_name: nil, **_kwargs)
    ApplicationFactory.find(application, environment).each do |app|
      app.deploy(url, deployment_name)
    end

    nil
  end
end

ApplicationDeployTask.run if $PROGRAM_NAME == __FILE__
