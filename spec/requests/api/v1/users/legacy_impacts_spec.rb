require 'rails_helper'

RSpec.describe 'Api::V1::Users::LegacyImpacts', type: :request do
  describe 'GET /index' do
    subject(:request) { get "/api/v1/users/#{user.id}/legacy_impacts" }

    let(:user) { create(:user) }
    let(:legacy_user) { create(:legacy_user, user:) }
    let(:legacy_non_profit) { create(:legacy_non_profit) }

    before do
      create(:legacy_user_impact, legacy_user:, legacy_non_profit:)
    end

    it 'returns the user impact by ngo' do
      request

      expect(response_json.first.keys)
        .to match_array %w[created_at donations_count
                           legacy_non_profit total_donated_usd total_impact updated_at]
    end
  end

  describe 'GET /legacy_contributions' do
    subject(:request) { get "/api/v1/users/#{user.id}/legacy_contributions" }

    let(:user) { create(:user) }
    let(:legacy_user) { create(:legacy_user, user:) }

    before do
      create(:legacy_contribution, legacy_user:)
    end

    it 'returns the user legacy contributions' do
      request

      expect(response_json.first.keys)
        .to match_array %w[id created_at updated_at day from_subscription legacy_payment_id legacy_payment_method
                           legacy_payment_platform legacy_user_id value_cents value]
    end
  end
end
