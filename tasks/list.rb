#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper'

require_relative 'utils/application_factory'

class ApplicationListTask < TaskHelper
  def task(**_kwargs)
    res = []

    ApplicationFactory.all.each do |app|
      deployments = app.deployments.map do |name, deployment|
        {
          name => {
            updated_at: deployment.updated_at.iso8601,
            active: deployment.active?,
          }
        }
      end.reduce(:merge)

      res << {
        application: app.name,
        environment: app.environment,
        path: app.path,
        deployments: deployments
      }
    end

    { status: res }
  end
end

ApplicationListTask.run if $PROGRAM_NAME == __FILE__
