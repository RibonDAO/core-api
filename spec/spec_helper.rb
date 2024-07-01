require 'simplecov'
require "webmock/rspec"
require 'vcr'

SimpleCov.start 'rails' do
  add_group "Blueprints", "app/blueprints"
  add_filter 'app/lib/redis_store'
  add_filter 'app/lib/simple_command'
  add_filter 'lib/generators'
  add_filter 'lib/ext'
  add_filter 'lib/tasks'
  add_filter 'app/lib/web3/providers/networks.rb'
  add_filter 'app/mailers/application_mailer.rb'
  add_filter 'app/channels/application_cable'
end
SimpleCov.minimum_coverage ENV["MIN_COVERAGE"].to_i if ENV["COVERAGE"]

VCR.configure do |config|
  config.cassette_library_dir = "spec/support/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.allow_http_connections_when_no_cassette = false
  config.before_record do |i|
    i.response.body.force_encoding('UTF-8')
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    Time.zone = "UTC"
  end
end
