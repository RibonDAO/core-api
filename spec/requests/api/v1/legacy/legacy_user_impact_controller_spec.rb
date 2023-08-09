require 'rails_helper'

RSpec.describe 'Api::V1::Legacy::LegacyUserImpactController', type: :request do
  describe 'POST /impact_by_non_profit with authorization token' do
    subject(:request) do
      post '/api/v1/legacy/create_legacy_impact', params:, headers: { AUTHORIZATION: 'Bearer LEGACY_API_TOKEN' }
    end

    let(:params) do
      { legacy_params: {
        user: {
          email: 'test@mail.com',
          legacy_id: '1',
          created_at: '2020-01-01'
        },
        impacts: [{ test: 'test' }]
      } }
    end

    before do
      allow(::Legacy::CreateLegacyUserImpactJob).to receive(:perform_later)
      request
    end

    it 'calls the CreateLegacyUserImpactJob with correct params' do
      expect(::Legacy::CreateLegacyUserImpactJob)
        .to have_received(:perform_later).with(strong_params(params[:legacy_params])[:user],
                                               strong_params(params[:legacy_params])[:impacts])
    end
  end

  describe 'POST /impact_by_non_profit without authorization token' do
    subject(:request) do
      post '/api/v1/legacy/create_legacy_impact', params:, headers: { AUTHORIZATION: 'Bearer test' }
    end

    let(:params) do
      { legacy_params: {} }
    end

    before do
      allow(::Legacy::CreateLegacyUserImpactJob).to receive(:perform_later)
      request
    end

    it 'calls the CreateLegacyUserImpactJob with correct params' do
      expect(::Legacy::CreateLegacyUserImpactJob)
        .not_to have_received(:perform_later)
    end
  end
end
