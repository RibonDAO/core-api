module Request
  class ApiRequest
    def self.get(url, expires_in: nil, headers: {})
      RedisStore::Cache.find_or_create(key: url&.parameterize, expires_in:) do
        HTTParty.get(url, headers:)
      end
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
