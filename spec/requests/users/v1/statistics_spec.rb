require 'rails_helper'

RSpec.describe 'Users::V1::Statistics', type: :request do
  describe 'GET /index' do
    include_context 'when making a user request' do
      subject(:request) { get "/users/v1/statistics?id#{user.id}&wallet_address=#{unique_identifier}", headers: }
    end

    let!(:wallet_address) { '0xA222222222222222222222222222222222222222' }
    let(:unique_identifier) { Base64.strict_encode64(wallet_address) }
    let(:crypto_user) { create(:crypto_user) }
    let(:user) { account.user }
    let(:customer) { create(:customer, user:, email: user.email) }
    let(:donations) { Donation.where(user:) }
    let(:result) { { total_causes: 0, total_tickets: 0, total_donated: { brl: 0, usd: 0 }, total_non_profits: 0 } }

    before do
      mock_command(klass: Users::CalculateStatistics, result:)
    end

    it 'returns the user statistics' do
      request

      expect_response_to_have_keys(%w[total_causes total_tickets total_donated total_non_profits
                                      last_donated_non_profit])
    end
  end
end
