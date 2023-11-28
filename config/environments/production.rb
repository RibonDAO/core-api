require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  Rails.application.routes.default_url_options[:host] = ENV['DEFAULT_HOST_URL']
  config.active_storage.service = :s3
  config.log_level = :info
  config.log_tags = [ :request_id ]
  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = [I18n.default_locale]
  config.active_support.report_deprecations = false
  config.log_formatter = ::Logger::Formatter.new
  config.active_job.queue_adapter = :sidekiq
  config.force_ssl = true
  config.ssl_options = {
    redirect: {
      exclude: -> request { request.path =~ /health/ }
    }
  }

  Rails.application.reloader.to_prepare do
    Dir["#{Rails.root}/app/models/rule_groups/*.rb"].each { |file| require_dependency file }
  end

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_record.dump_schema_after_migration = false
end
