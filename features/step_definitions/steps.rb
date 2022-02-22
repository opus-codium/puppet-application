require_relative '../../tasks/utils/application'

Given('an application {string}') do |application|
  @tmp_dir = Dir.mktmpdir
  @application_dir = "#{@tmp_dir}/#{application}"
  @application = Application.new(name: application, path: @application_dir)
end

Given('the following deployments:') do |table|
  table.hashes.each do |row|
    step(%(I create a deployment "#{row[:name]}"))
  end
end

When('I create a deployment {string}') do |name|
  @application.deploy(nil, name)
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
  begin
    step(%(I remove the deployment "#{name}"))
  rescue StandardError => e
    @last_error = e.message
  end
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
