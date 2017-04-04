
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require "spec_helper"
require "rspec/rails"
require "support/easy_screenshots"
require "capybara/poltergeist"

Capybara.javascript_driver = :poltergeist
Capybara.default_driver    = :poltergeist

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.add_setting :screenshots_dir
  config.screenshots_dir = "#{::Rails.root}/spec/screenshots"
  config.include(EasyScreenshots, type: :feature)

  config.before(:suite) do
    unless ENV["CI"] == "true"
    $webpack_dev_server_pid = spawn(
      "./node_modules/.bin/webpack-dev-server " +
        "--config config/webpack.config.js --quiet")
    end
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, type: :feature) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.after(:suite) do
    unless ENV["CI"] == "true"
      puts "Killing webpack-dev-server"
      Process.kill("HUP",$webpack_dev_server_pid)
      begin
        Timeout.timeout(2) do
          Process.wait($webpack_dev_server_pid,0)
        end
      rescue => Timeout::Error
        Process.kill(9,$webpack_dev_server_pid)
      end
    end
  end
end
