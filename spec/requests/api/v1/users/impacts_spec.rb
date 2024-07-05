require 'rails_helper'

RSpec.describe 'Api::V1::Users::Impacts', type: :request do
  describe 'GET /index' do
    subject(:request) { get "/api/v1/users/#{user.id}/impacts" }

    let(:user) { create(:user) }
    let(:non_profit) { build(:non_profit) }

    before do
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:impact).and_return([{
                                                   non_profit:,
                                                   impact: 5
                                                 }])
    end

    it 'returns the user impact by ngo' do
      request

      expect(response_json.first.keys).to match_array %w[donation_count impact non_profit]
    end
  end

  describe 'GET /donations_count' do
    subject(:request) { get "/api/v1/users/#{user.id}/donations_count" }

    let(:user) { create(:user) }
    let(:non_profit) { build(:non_profit) }
    let(:donation) { build(:donation) }

    before do
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:donations).and_return([donation, donation])
    end

    it 'returns the total amount of donations from the user' do
      request

      expect(response_body.donations_count).to eq 2
    end
  end

  describe 'GET app/donations_count' do
    subject(:request) { get "/api/v1/users/#{user.id}/app/donations_count" }

    let!(:user) { create(:user) }

    before do
      create(:donation, platform: :web, user:)
      create(:donation, platform: :app, user:)
    end

    it 'returns the total amount of donations from the user' do
      request

      expect(response_body.app_donations_count).to eq 1
    end
  end
end
