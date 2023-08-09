class String
  def valid_uuid?
    uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

    return true if uuid_regex.match?(to_s.downcase)

    false
  end

  def to_bool
    ActiveModel::Type::Boolean.new.cast(self)
  end
end
