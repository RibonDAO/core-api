module Users
  class HandlePostUserJob < ApplicationJob
    queue_as :default

    def perform(user:)
      update_legacy_id(user)
    rescue StandardError
      nil
    end

    def update_legacy_id(user)
      legacy_user = LegacyUser.find_by(email: user.email)
      legacy_user&.update!(user:)
    end
  end
end
