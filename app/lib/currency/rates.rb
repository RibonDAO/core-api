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

    def rate
      response = Request::ApiRequest.get(request_url, expires_in: 2.hours)
      response["#{from.upcase}#{to.upcase}"]['ask']
    rescue StandardError
      response = Request::ApiRequest.get(backup_request_url, expires_in: 2.hours)
      response['rates'][to.upcase]
    end

    private

    def request_url
      "#{RibonCoreApi.config[:currency_api][:url]}#{from}-#{to}"
    end

    def backup_request_url
      "#{RibonCoreApi.config[:currency_api][:backup_url]}?base=#{from}"
    end
  end
end
