require 'rails_helper'

RSpec.describe 'Users::V1::Tickets::Collect', type: :request do
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
        allow(Tracking::AddUtmJob).to receive(:perform_later)
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
        expect(Tracking::AddUtmJob).to have_received(:perform_later)
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

  describe 'POST /collect_by_external_ids' do
    include_context 'when making a user request' do
      subject(:request) { post '/users/v1/tickets/collect_by_external_ids', headers:, params: }
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
        allow(Tickets::CollectByExternalIds).to receive(:call)
          .and_return(command_double(klass: Tickets::CollectByExternalIds))
        allow(Tracking::AddUtmJob).to receive(:perform_later)
          .and_return(command_double(klass: Tracking::AddUtm))
      end

      it 'calls the CollectByExternalId command with right params' do
        request

        expect(Tickets::CollectByExternalIds).to have_received(:call).with(
          integration:,
          user:,
          platform:,
          external_ids:
        )
      end

      it 'calls add utm command' do
        request
        expect(Tracking::AddUtmJob).to have_received(:perform_later)
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

  describe 'POST /collect_by_club' do
    include_context 'when making a user request' do
      subject(:request) { post '/users/v1/tickets/collect_by_club', headers:, params: }
    end

    context 'with right params' do
      let(:user) { account.user }
      let(:platform) { 'web' }
      let(:category) { 'daily' }
      let(:params) do
        {
          platform:,
          category:
        }
      end

      before do
        allow(Tickets::CollectByClub).to receive(:call)
          .and_return(command_double(klass: Tickets::CollectByClub))
      end

      it 'calls the CollectByClub command with right params' do
        request
        expect(Tickets::CollectByClub).to have_received(:call).with(
          user:,
          platform:,
          category:
        )
      end

      it 'returns success' do
        request

        expect(response).to have_http_status :ok
      end

      it 'returns the tickets' do
        request

        expect_response_to_have_keys(%w[tickets])
      end
    end

    context 'with wrong params' do
      let(:params) do
        {
          category: 'daily'
        }
      end

      it 'returns an error' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
