module Request
  class ApiRequest
    def self.get(url, expires_in: nil, headers: {})
      cached_response = RedisStore::Cache.find(url&.parameterize)
      return cached_response if cached_response

      response = HTTParty.get(url, headers:)

      if response.code == 200
        RedisStore::Cache.find_or_create(key: url&.parameterize, expires_in:) do
          response
        end
      end

      response
    end

    def self.post(url, body:, headers: {})
      default_headers = { 'Content-Type' => 'application/json' }
      HTTParty.post(url, body:, headers: default_headers.merge(headers))
    end

    def self.delete(url, headers: {})
      HTTParty.delete(url, headers:)
    end
  end
end
