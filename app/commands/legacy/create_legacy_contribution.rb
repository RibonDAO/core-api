module Legacy
  class CreateLegacyContribution < ApplicationCommand
    prepend SimpleCommand

    attr_reader :impacts, :email, :legacy_id, :created_at, :legacy_contribution

    def initialize(legacy_user:, legacy_contribution:)
      @email = legacy_user[:email]
      @legacy_id = legacy_user[:legacy_id]
      @created_at = legacy_user[:created_at]
      @legacy_contribution = legacy_contribution
    end

    def call
      with_exception_handle do
        LegacyContribution.create!(
          legacy_user:,
          day: legacy_contribution[:created_at],
          value_cents: legacy_contribution[:value_cents],
          legacy_payment_id: legacy_contribution[:legacy_payment_id],
          legacy_payment_method: legacy_contribution[:legacy_payment_method],
          legacy_payment_platform: legacy_contribution[:legacy_payment_platform],
          from_subscription: legacy_contribution[:from_subscription]
        )
      end
    end

    private

    def legacy_user
      l_user = LegacyUser.where(email:).first

      unless l_user
        user = User.where(email:).first
        l_user = LegacyUser.create!(email:, legacy_id:, created_at:, user:)
      end

      l_user
    end
  end
end
