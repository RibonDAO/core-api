module UserServices
  class UserImpact
    attr_reader :user
    attr_reader :donations_by_non_profit

    def initialize(user:)
      @user = user
      @donations_by_non_profit = user
                                  .donations
                                  .includes(non_profit: [:non_profit_impacts])
                                  .group_by(&:non_profit)
    end

    def impact
      donations_by_non_profit.map do |non_profit, donations|
        {
          non_profit:,
          impact: impact_sum(non_profit, donations),
          donation_count: donation_count(donations)
        }
      end
    end

    private

    def impact_sum(non_profit, donations) 
      usd_to_impact_factor = non_profit.impact_for&.usd_cents_to_one_impact_unit
      return 0 unless usd_to_impact_factor

      (total_usd_cents_donated(donations) / usd_to_impact_factor).to_i
    end

    def donation_count(donations)
      donations.count
    end

    def total_usd_cents_donated(donations)
      donations.sum(&:value)
    end
  end
end
