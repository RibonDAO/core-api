require 'rails_helper'

RSpec.describe 'Users::V1::Integrations', type: :request do
  describe 'POST /create' do
    include_context 'when making a user request' do
      let(:request) { post '/users/v1/integration', headers:, params: }
    end

    let!(:user_id) { account.user.id }

    let(:params) do
      {
        name: 'Ribon',
        status: :inactive,
        metadata: { user_id: }.to_json,
      }
    end

    let!(:result) { create(:integration, metadata: { user_id: }) }

    before do
      mock_command(klass: Integrations::CreateIntegration, result:)
      request
    end


    it 'expect metadata to have an user_id' do
      expect(result.metadata['user_id']).to eq(user_id)
    end

    it 'returns a single integration' do
      expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                      integration_address integration_wallet logo
                                      integration_task ticket_availability_in_minutes webhook_url
                                      integration_dashboard_address])
    end
  end

  describe 'GET /show' do
    include_context 'when making a user request' do
      let(:request) { get "/users/v1/integration", headers: }
    end

    before do
      create(
        :integration,
        metadata: { user_id: account.user.id },
        name: 'Ribon',
        status: :active
      )
    end

    it 'returns a single integration' do
      request

      expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                      integration_address integration_wallet logo
                                      integration_task ticket_availability_in_minutes webhook_url
                                      integration_dashboard_address])
    end
  end
end
