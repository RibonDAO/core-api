# frozen_string_literal: true

class Reporter
  def self.log(error:, extra: {}, level: :error)
    Sentry.capture_exception(error, level:, extra:) if Rails.env.production?
  end
end
