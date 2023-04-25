require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RibonCoreApi
  extend self

  def redis
    @redis ||= Redis::Namespace.new('api', redis: Redis.new(url: redis_url))
  end

  def redis_url
    @redis_url ||= config[:redis][:url]
  end

  def load_yaml(config)
    config_file = ERB.new(File.read("#{Rails.root}/config/#{config}.yml")).result
    YAML.safe_load(config_file, permitted_classes: [], permitted_symbols: [], aliases: true)
  end

  def config
    @config ||= RecursiveOpenStruct.new(load_yaml('env')[Rails.env])
  end

  class Application < Rails::Application
    config.load_defaults 7.0

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Flash
    config.middleware.use Rack::MethodOverride
    config.middleware.use ActionDispatch::Session::CookieStore, {:key=>"_ribon_core_api_session"}
    config.autoload_paths += Dir[Rails.root.join('app', 'models', '**/')]
    config.cache_store = :redis_cache_store, { url: RibonCoreApi.redis_url, namespace: "ribon_core_api:cache" }
    config.active_job.queue_adapter = :sidekiq
    config.time_zone = 'Brasilia'
    config.active_storage.silence_invalid_content_types_warning = true
    config.active_record.observers = [:donation_observer, :person_payment_observer, :user_observer]
    config.api_only = true
  end
end
