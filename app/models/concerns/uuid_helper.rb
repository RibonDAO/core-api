module UuidHelper
  extend ActiveSupport::Concern

  module ClassMethods
    def first
      order('created_at').first
    end

    def last
      order('created_at DESC').first
    end
  end
end
