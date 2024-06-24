require 'rails_helper'

RSpec.describe UserServices::UserImpact, type: :service do
  ActiveRecord.verbose_query_logs = true
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  describe '#impact' do
    let(:user) { create(:user, email: 'user@test.com') }
    let(:non_profit1) do
      create(:non_profit, :with_impact, wallet_address: '0xA000000000000000000000000000000000000000')
    end
    let(:non_profit2) do
      create(:non_profit, :with_impact, wallet_address: '0xA111111111111111111111111111111111111111')
    end
    let(:integration) { create(:integration) }

    before do
      create_list(:donation, 5, user:, value: 15, non_profit: non_profit1, integration:)
      create_list(:donation, 3, user:, value: 15, non_profit: non_profit2, integration:)
    end

    it 'returns the sum of impact of each non profit' do
      user_impact = user.impact

      expect(user_impact)
        .to match_array [{ impact: 7, non_profit: non_profit1,
                           donation_count: 5 },
                         { impact: 4, non_profit: non_profit2,
                           donation_count: 3 }]
    end
  end
end
