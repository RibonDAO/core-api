require 'rails_helper'

RSpec.describe 'Users::V1::Tickets', type: :request do
  describe 'POST /can_collect_by_integration' do
    include_context 'when making a user request' do
      subject(:request) { post '/users/v1/tickets/can_collect_by_integration', headers:, params: }
    end

    context 'with right params' do
      let(:integration) { create(:integration) }
      let(:user) { account.user }
      let(:params) do
        {
          integration_id: integration.id
        }
      end

      before do
        allow(Tickets::CanCollectByIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CanCollectByIntegration))
        allow(Tickets::CollectByIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CollectByIntegration))
        allow(Tracking::AddUtm).to receive(:call)
          .and_return(command_double(klass: Tracking::AddUtm))
      end

      it 'calls the CanCollectByIntegration command with right params' do
        request

        expect(Tickets::CanCollectByIntegration).to have_received(:call).with(
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
          integration: integration.id
        }
      end

      it 'returns an error' do
        request

        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'POST /collect_by_integration' do
    include_context 'when making a user request' do
      subject(:request) { post '/users/v1/tickets/collect_by_integration', headers:, params: }
    end

    context 'with right params' do
      let(:integration) { create(:integration) }
      let(:user) { account.user }
      let(:platform) { 'web' }
      let(:params) do
        {
          integration_id: integration.id,
          platform:,
          utm_source: 'utm source',
          utm_medium: 'utm medium',
          utm_campaign: 'utm campaign'
        }
      end

      before do
        allow(Tickets::CanCollectByIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CanCollectByIntegration))
        allow(Tickets::CollectByIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CollectByIntegration))
        allow(Tracking::AddUtm).to receive(:call)
          .and_return(command_double(klass: Tracking::AddUtm))
      end

      it 'calls the CollectByIntegration command with right params' do
        request

        expect(Tickets::CollectByIntegration).to have_received(:call).with(
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
          integration: integration.id
        }
      end

      it 'returns an error' do
        request

        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'POST /collect_by_external_id' do
    include_context 'when making a user request' do
      subject(:request) { post '/users/v1/tickets/collect_by_external_id', headers:, params: }
    end

    context 'with right params' do
      let(:integration) { create(:integration) }
      let(:user) { account.user }
      let(:platform) { 'web' }
      let(:external_ids) { ['13'] }
      let(:params) do
        {
          integration_id: integration.id,
          platform:,
          external_ids:,
          utm_source: 'utm source',
          utm_medium: 'utm medium',
          utm_campaign: 'utm campaign'
        }
      end

      before do
        allow(Tickets::CanCollectByExternalId).to receive(:call)
          .and_return(command_double(klass: Tickets::CanCollectByExternalId))
        allow(Tickets::CollectByExternalId).to receive(:call)
          .and_return(command_double(klass: Tickets::CollectByExternalId))
        allow(Tracking::AddUtm).to receive(:call)
          .and_return(command_double(klass: Tracking::AddUtm))
      end

      it 'calls the CollectByExternalId command with right params' do
        request

        expect(Tickets::CollectByExternalId).to have_received(:call).with(
          integration:,
          user:,
          platform:,
          external_ids:
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
          integration: integration.id
        }
      end

      it 'returns an error' do
        request

        expect(response).to have_http_status :not_found
      end
    end
  end
end
