require 'rails_helper'

RSpec.describe 'Users::V1::Impacts::Impacts', type: :request do
  describe 'GET /index' do
    include_context 'when making a user request' do
      subject(:request) { get '/users/v1/impacts/impacts', headers: }
    end

    let(:user) { account.user }
    let(:non_profit) { build(:non_profit) }

    before do
      create(:donation, user:)
    end

    it 'returns the user impact by ngo' do
      request

      expect(response_json.first.keys).to match_array %w[impact non_profit]
    end
  end

  describe 'GET /donations_count' do
    include_context 'when making a user request' do
      subject(:request) { get '/users/v1/impacts/donations_count', headers: }
    end

    let(:user) { account.user }

    before do
      create(:donation, user:)
      create(:donation, user:)
    end

    it 'returns the total amount of donations from the user' do
      request

      expect(response_body.donations_count).to eq 2
    end
  end

  describe 'GET app/donations_count' do
    include_context 'when making a user request' do
      subject(:request) { get '/users/v1/impacts/app/donations_count', headers: }
    end

    let!(:user) { account.user }

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
