module Users
  class HandlePostUserJob < ApplicationJob
    queue_as :default

    def perform(user:)
      update_legacy_id(user)
    rescue StandardError
      nil
    end

    def update_legacy_id(user)
      legacy_user_impacts = LegacyUserImpact.where(user_email: user.email)
      return unless legacy_user_impacts

      user.update(legacy_id: legacy_user_impacts.first.user_legacy_id,
                  created_at: legacy_user_impacts.first.user_created_at)
      legacy_user_impacts.update(user:)
    end
  end
end
