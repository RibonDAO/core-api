module Legacy
  class CreateLegacyContribution < ApplicationCommand
    prepend SimpleCommand
    require 'open-uri'

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
          user:,
          day: legacy_contribution[:created_at],
          value_cents: legacy_contribution[:value_cents],
          legacy_payment_id: legacy_contribution[:legacy_payment_id],
          legacy_payment_method: legacy_contribution[:legacy_payment_method],
          legacy_payment_platform: legacy_contribution[:legacy_payment_platform]
        )
      end
    end

    private

    def user
      user = User.where(email:).first
      user&.update!(legacy_id:, created_at:)
      user
    end
  end
end
