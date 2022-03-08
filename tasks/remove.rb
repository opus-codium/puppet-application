#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper'

require_relative 'utils/application_factory'

class ApplicationActivateTask < TaskHelper
  def task(application:, environment:, deployment_name:, **_kwargs)
    ApplicationFactory.find(application, environment).each do |app|
      deployment = app.deployments[deployment_name]
      deployment.remove
    end

    nil
  end
end

ApplicationActivateTask.run if $PROGRAM_NAME == __FILE__
