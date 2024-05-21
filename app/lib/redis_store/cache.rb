# frozen_string_literal: true

module RedisStore
  module Cache
    module_function

    def find_or_create(key: nil, expires_in: nil, &block)
      return Rails.cache.fetch(key, expires_in:, &block) if expires_in

      yield
    end

    def find(key)
      Rails.cache.read(key)
    end
  end
end
