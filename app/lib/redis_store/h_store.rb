# frozen_string_literal: true

module RedisStore
  module HStore
    extend self

    def set(key:, value:, field: nil, **options)
      field_attr = field || key
      entry = Entry.new(value:, expires_in: options[:expires_in])
      redis.hset(key, field_attr, serialize(value: entry))

      entry.value
    end

    def get(key:, field: nil)
      field_attr = field || key
      entry = deserialize(value: redis.hget(key, field_attr))
      return if entry.blank?

      if entry.expired?
        del(key:, field: field_attr)
        return nil
      end

      entry.value
    end

    def del(key:, field: nil)
      field_attr = field || key
      redis.hdel(key, field_attr)
    end

    private

    def serialize(value:)
      value.to_json
    end

    def deserialize(value:)
      return if value.nil?

      RestoredEntry.new(JSON.parse(value, symbolize_names: true))
    end

    def redis
      RibonCoreApi.redis
    end
  end
end
