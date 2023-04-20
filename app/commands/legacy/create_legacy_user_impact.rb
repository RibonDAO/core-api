module Legacy
  class CreateLegacyUserImpact < ApplicationCommand
    prepend SimpleCommand

    attr_reader :email, :impacts, :legacy_id

    def initialize(email:, impacts:, legacy_id:)
      @email = email
      @impacts = impacts
      @legacy_id = legacy_id
    end

    def call
      with_exception_handle do
        impacts.each do |impact|
          legacy_user_impact = LegacyUserImpact.where(user:,
                                                      legacy_non_profit: legacy_non_profit(impact[:non_profit]))
                                               .first_or_create(legacy_user_impact_params(impact))
          legacy_user_impact.save!
        end
      end
    end

    private

    def legacy_user_impact_params(impact)
      {
        user:,
        legacy_non_profit: legacy_non_profit(impact[:non_profit]),
        total_impact: impact[:total_impact],
        total_donated_usd: impact[:total_donated_usd],
        donations_count: impact[:donations_count]
      }
    end

    def user
      @user ||= User.find_or_create_by(email:)
      @user.update!(legacy_id: @legacy_id)
      @user
    end

    def legacy_non_profit(non_profit)
      non_profit_params = legacy_non_profit_params(non_profit)
      LegacyNonProfit.where(name: non_profit_params[:name])
                     .first_or_create(non_profit_params)
    end

    def legacy_non_profit_params(non_profit)
      {
        name: non_profit[:name],
        logo_url: non_profit[:logo_url],
        cost_of_one_impact: non_profit[:cost_of_one_impact],
        impact_description: non_profit[:impact_description],
        legacy_id: non_profit[:legacy_id]
      }
    end
  end
end
