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

  describe 'POST /donate' do
    include_context 'when making a user request' do
      subject(:request) { post '/users/v1/tickets/donate', headers:, params: }
    end

    context 'with right params' do
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:user) { create(:user) }
      let(:platform) { 'web' }
      let(:params) do
        {
          integration_id: integration.id,
          platform:,
          non_profit_id: non_profit.id,
          email: user.email,
          quantity: 1
        }
      end

      before do
        create(:chain)
        create_list(:ticket, 2, user:, integration:)
        create(:ribon_config, default_ticket_value: 100)
        allow(Tickets::Donate).to receive(:call)
          .and_return(command_double(klass: Tickets::Donate))
      end

      it 'calls the donate command with right params' do
        request

        expect(Tickets::Donate).to have_received(:call).with(
          integration:,
          user:,
          platform:,
          non_profit:,
          quantity: '1'
        )
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
  end
end
