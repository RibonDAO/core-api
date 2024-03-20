require 'rails_helper'

RSpec.describe 'Api::V1::Integrations', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/api/v1/integrations' }

    before do
      create_list(:integration, 2)
    end

    it 'returns a list of integrations' do
      request

      expect_response_collection_to_have_keys(%w[created_at id updated_at name status unique_address
                                                 integration_address integration_wallet logo
                                                 integration_task ticket_availability_in_minutes webhook_url
                                                 integration_dashboard_address])
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/api/v1/integrations', params: }

    let(:params) do
      {
        name: 'Ribon',
        status: :inactive
      }
    end

    let!(:result) { create(:integration) }

    before do
      mock_command(klass: Integrations::CreateIntegration, result:)
      request
    end

    it 'returns a single integration' do
      expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                      integration_address integration_wallet logo
                                      integration_task ticket_availability_in_minutes webhook_url
                                      integration_dashboard_address])
    end
  end

  describe 'GET /show' do
    context 'when id is numeric' do
      subject(:request) { get "/api/v1/integrations/#{integration.id}" }

      let(:integration) { create(:integration) }

      it 'returns a single integration' do
        request

        expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                        integration_address integration_wallet logo
                                        integration_task ticket_availability_in_minutes webhook_url
                                        integration_dashboard_address])
      end

      context 'when id is uuid' do
        subject(:request) { get "/api/v1/integrations/#{integration.unique_address}" }

        let(:integration) { create(:integration) }

        it 'returns a single integration' do
          request

          expect_response_to_have_keys(%w[created_at id updated_at name status unique_address
                                          integration_address integration_wallet logo
                                          integration_task ticket_availability_in_minutes webhook_url
                                          integration_dashboard_address])
        end
      end
    end
  end

  describe 'PUT /update' do
    subject(:request) { put "/api/v1/integrations/#{integration.id}", params: }

    let(:integration) { create(:integration) }
    let(:params) { { name: 'New Name' } }

    it 'updates the integration' do
      request

      expect(integration.reload.name).to eq('New Name')
    end
  end
end
