# frozen_string_literal: true

require_relative '../../tasks/utils/application'

Given('an application {string}') do |application|
  step(%(an application "#{application}" with retention 1..∞))
end

Given('an application {string} with retention {int}..{word}') do |application, min, max|
  max = if max == '∞'
          nil
        else
          Integer(max)
        end

  @tmp_dir = Dir.mktmpdir
  @application_dir = "#{@tmp_dir}/#{application}"
  @application = Application.new(title: application, name: application, path: @application_dir, environment: 'production', deploy_user: Process.uid, deploy_group: Process.gid, user_mapping: {}, group_mapping: {}, retention_min: min, retention_max: max)
end

Given('the following deployments:') do |table|
  table.hashes.each do |row|
    step(%(I create a deployment "#{row[:name]}"))
  end
end

When('I create a deployment {string}') do |name|
  @application.deploy(nil, name, {})
  workaround_async_ci
end

When('I activate the deployment {string}') do |name|
  @application.deployments[name].activate
  workaround_async_ci
end

When('I remove the deployment {string}') do |name|
  @application.deployments[name].remove
end

When('I remove the deployment {string} catching errors') do |name|
  step(%(I remove the deployment "#{name}"))
rescue StandardError => e
  @last_error = e.message
end

When('I prune old deployments keeping the last {int}') do |keep|
  @application.prune(keep)
end

Then('the current deployment should be {string}') do |target|
  step(%(the symbolic link "current" should point to "#{target}"))
end

Then('the symbolic link {string} should point to {string}') do |link, target|
  expect(File.lstat("#{@application_dir}/#{link}").symlink?).to be_truthy
  expect(File.stat("#{@application_dir}/#{link}").ino).to eq(File.stat("#{@application_dir}/#{target}").ino)
end

Then('the deployment {string} should not exist') do |name|
  expect(File.exist?("#{@application_dir}/#{name}")).to be_falsey
end

Then('the deployment {string} should exist') do |name|
  expect(File.directory?("#{@application_dir}/#{name}")).to be_truthy
end

Then('the deployments should be:') do |table|
  expect(@application.deployments.keys).to eq(table.hashes.map { |row| row[:name] })
end

Then('the error {string} should have been catch') do |message|
  expect(@last_error).to eq(message)
end
