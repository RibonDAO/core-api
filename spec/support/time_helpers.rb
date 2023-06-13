# frozen_string_literal: true

module TimeHelpers
  def parsed_date(date_time_string)
    DateTime.parse(date_time_string)
  end

  def mock_now(date_time_string)
    allow(Time.zone).to receive(:now).and_return(parsed_date(date_time_string))
  end
end

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
end
