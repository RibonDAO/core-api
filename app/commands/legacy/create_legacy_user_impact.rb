module Legacy
  class CreateLegacyUserImpact < ApplicationCommand
    prepend SimpleCommand
    require 'open-uri'

    attr_reader :impacts, :email, :legacy_id, :created_at

    def initialize(legacy_user:, legacy_impacts:)
      @email = legacy_user[:email]
      @legacy_id = legacy_user[:legacy_id]
      @created_at = legacy_user[:created_at]
      @impacts = legacy_impacts
    end

    def call
      with_exception_handle do
        impacts.each do |impact|
          LegacyUserImpact.where(legacy_user:)
                          .where(legacy_non_profit: legacy_non_profit(impact[:non_profit]))
                          .first_or_create(legacy_user_impact_params(impact))
        end
      end
    end

    private

    def legacy_user_impact_params(impact)
      {
        legacy_user:,
        legacy_non_profit: legacy_non_profit(impact[:non_profit]),
        total_impact_en: impact[:total_impact_en],
        total_impact_pt_br: impact[:total_impact_pt_br],
        total_donated_usd: impact[:total_donated_usd],
        donations_count: impact[:donations_count]
      }
    end

    def legacy_user
      l_user = LegacyUser.where(email:).first

      unless l_user
        user = User.where(email:).first
        l_user = LegacyUser.create!(email:, legacy_id:, created_at:, user:)
      end

      l_user
    end

    def legacy_non_profit(non_profit)
      non_profit_params = legacy_non_profit_params(non_profit)
      legacy_non_profit = LegacyNonProfit.where(name: non_profit_params[:name])
                                         .first_or_create(non_profit_params)
      non_profit_logo(legacy_non_profit) unless legacy_non_profit.logo.attached?
      update_current_id(legacy_non_profit) if legacy_non_profit.current_id.nil?
      legacy_non_profit
    end

    def legacy_non_profit_params(non_profit)
      {
        name: non_profit[:name],
        logo_url: non_profit[:logo_url],
        impact_cost_ribons: non_profit[:impact_cost_ribons],
        impact_cost_usd: non_profit[:impact_cost_usd],
        impact_description_en: non_profit[:impact_description_en],
        impact_description_pt_br: non_profit[:impact_description_pt_br],
        legacy_id: non_profit[:legacy_id]
      }
    end

    def non_profit_logo(non_profit)
      url = URI.parse(non_profit.logo_url)
      filename = File.basename(url.path)
      # rubocop:disable Security/Open
      file = URI.open(url)
      # rubocop:enable Security/Open
      non_profit.logo.attach(io: file, filename:)
    rescue StandardError => e
      Rails.logger.error "Error attaching logo to non profit #{non_profit&.name}: #{e}"
    end

    def update_current_id(legacy_non_profit)
      non_profit = NonProfit.where(name: legacy_non_profit.name).first
      legacy_non_profit.update!(current_id: non_profit.id) if non_profit.present?
    end
  end
end
