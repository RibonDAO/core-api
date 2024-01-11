require 'rails_helper'

RSpec.describe 'Api::V1::Tickets::Collect', type: :request do
  describe 'POST /can_collect_by_integration' do
    subject(:request) { post '/api/v1/tickets/can_collect_by_integration', params: }

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

  describe 'POST /collect_by_integration' do
    subject(:request) { post '/api/v1/tickets/collect_by_integration', params: }

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

  describe 'POST /collect_and_donate_by_integration' do
    subject(:request) { post '/api/v1/tickets/collect_and_donate_by_integration', params: }

    context 'with right params' do
      let(:integration) { create(:integration) }
      let(:user) { create(:user) }
      let(:platform) { 'web' }
      let(:non_profit) { create(:non_profit) }
      let(:params) do
        {
          integration_id: integration.id,
          email: user.email,
          platform:,
          non_profit_id: non_profit.id,
          utm_source: 'utm source',
          utm_medium: 'utm medium',
          utm_campaign: 'utm campaign'
        }
      end

      before do
        allow(Tickets::CanCollectByIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CanCollectByIntegration))
        allow(Tickets::CollectAndDonateByIntegration).to receive(:call)
          .and_return(command_double(klass: Tickets::CollectAndDonateByIntegration))
        allow(Tracking::AddUtm).to receive(:call)
          .and_return(command_double(klass: Tracking::AddUtm))
      end

      it 'calls the CollectAndDonateByIntegration command with right params' do
        request

        expect(Tickets::CollectAndDonateByIntegration).to have_received(:call).with(
          integration:,
          user:,
          platform:,
          non_profit:
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

      it 'returns the donation' do
        request

        expect_response_to_have_keys(%w[donation])
      end
    end

    context 'with wrong params' do
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit) }
      let(:params) do
        {
          integration_id: integration.id,
          non_profit_id: non_profit.id,
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
