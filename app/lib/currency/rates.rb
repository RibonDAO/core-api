module Currency
  class Rates
    attr_reader :from, :to

    def initialize(from:, to:)
      @from = from
      @to = to
    end

    def add_rate
      Money.add_rate(from, to, rate)
    end

    # rubocop:disable Metrics/AbcSize
    def rate
      response = Request::ApiRequest.get(request_url, headers:, expires_in: 2.hours)
      response['data'][to.upcase.to_s]['value']
    rescue StandardError
      response = Request::ApiRequest.get(backup_request_url, expires_in: 2.hours)
      response['rates'][to.upcase]
    end
    # rubocop:enable Metrics/AbcSize

    private

    def request_url
      "#{RibonCoreApi.config[:currency_api][:url]}?base_currency=#{from.upcase}&currencies=#{to.upcase}"
    end

    def headers
      { apikey: RibonCoreApi.config[:currency_api][:api_key] }
    end

    def backup_request_url
      "#{RibonCoreApi.config[:currency_api][:backup_url]}?base=#{from}"
    end
  end
end
