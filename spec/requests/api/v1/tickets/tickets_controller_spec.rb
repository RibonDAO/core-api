require 'rails_helper'

RSpec.describe 'Api::V1::Tickets', type: :request do
  describe 'POST /can_collect_from_integration' do
    subject(:request) { post '/api/v1/tickets/can_collect_from_integration', params: }

    context 'with right params' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }
      let(:params) do
        {
          integration_id: integration.id,
          email: user.email
        }
      end

      before do
        allow(Tickets::CanCollectFromIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CanCollectFromIntegration))
        allow(Tickets::CollectFromIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CollectFromIntegration))
        allow(Tracking::AddUtm).to receive(:call)
          .and_return(command_double(klass: Tracking::AddUtm))
      end

      it 'calls the CanCollectFromIntegration command with right params' do
        request

        expect(Tickets::CanCollectFromIntegration).to have_received(:call).with(
          integration:,
          user:
        )
      end

      it 'returns true' do
        request

        expect(response.body['can_collect']).to be_truthy
      end
    end

    context 'with wrong params' do
      let(:integration) { create(:integration) }
      let(:params) do
        {
          integration_id: integration.id,
          email: 1
        }
      end

      it 'returns an error' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'POST /collect_from_integration' do
    subject(:request) { post '/api/v1/tickets/collect_from_integration', params: }

    context 'with right params' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }
      let(:platform) { 'web' }
      let(:params) do
        {
          integration_id: integration.id,
          email: user.email,
          platform:,
          utm_source: 'utm source',
          utm_medium: 'utm medium',
          utm_campaign: 'utm campaign'
        }
      end

      before do
        allow(Tickets::CanCollectFromIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CanCollectFromIntegration))
        allow(Tickets::CollectFromIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CollectFromIntegration))
        allow(Tracking::AddUtm).to receive(:call)
          .and_return(command_double(klass: Tracking::AddUtm))
      end

      it 'calls the CollectFromIntegration command with right params' do
        request

        expect(Tickets::CollectFromIntegration).to have_received(:call).with(
          integration:,
          user:,
          platform:
        )
      end

      it 'calls add utm command' do
        request
        expect(Tracking::AddUtm).to have_received(:call)
      end

      it 'returns success' do
        request

        expect(response).to have_http_status :ok
      end

      it 'returns the ticket' do
        request

        expect_response_to_have_keys(%w[ticket])
      end
    end

    context 'with wrong params' do
      let(:integration) { create(:integration) }
      let(:params) do
        {
          integration_id: integration.id,
          email: 1
        }
      end

      it 'returns an error' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
