#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper'

require_relative 'utils/application_factory'

class ApplicationPruneTask < TaskHelper
  def task(application:, environment:, keep:, **_kwargs)
    ApplicationFactory.find(application, environment).each do |app|
      app.prune(keep)
    end

    nil
  end
end

ApplicationPruneTask.run if $PROGRAM_NAME == __FILE__
