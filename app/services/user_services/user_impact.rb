module UserServices
  module UserImpact
    def impact
      donation_balances = Graphql::RibonApi::Client.query(Graphql::Queries::FetchDonationBalances::Query)
      user_donations = select_from_donation_balances(donation_balances)

      non_profits.map { |non_profit| format_result(non_profit, user_donations) }
    end

    private

    def select_from_donation_balances(donation_balances)
      donation_balances.original_hash['data']['donationBalances'].select do |donation|
        donation['user'] == hashed_email
      end
    end

    def hashed_email
      "0x#{Digest::Keccak.new(256).hexdigest(email)}"
    end

    def format_result(non_profit, user_donations)
      { non_profit:, impact: impact_sum_by_non_profit(user_donations, non_profit) }
    end

    def impact_sum_by_non_profit(user_donations, non_profit)
      donations = non_profit_donations(user_donations, non_profit)
      usd_to_impact_factor = non_profit.impact_for(date: Time.zone.now).usd_cents_to_one_impact_unit

      total_usd_cents_donated(donations) / usd_to_impact_factor
    end

    def non_profit_donations(user_donations, non_profit)
      user_donations.select { |donation| donation['nonProfit'].casecmp(non_profit.wallet_address).zero? }
    end

    def total_usd_cents_donated(donations)
      total_donated = donations.sum { |donation| donation['totalDonated'].to_i }
      total_donated_in_cents = total_donated * 100

      Web3::Utils::Converter.parse_wei(total_donated_in_cents)
    end

    def non_profits
      NonProfit.all
    end
  end
end
