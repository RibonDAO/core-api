require 'rails_helper'

RSpec.describe 'Users::V1::Tickets::Donations', type: :request do
  describe 'POST /donate' do
    include_context 'when making a user request' do
      subject(:request) { post '/users/v1/tickets/donate', headers:, params: }
    end

    context 'with right params' do
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:user) { account.user }
      let(:platform) { 'web' }
      let(:params) do
        {
          platform:,
          non_profit_id: non_profit.id,
          email: user.email,
          quantity: 1
        }
      end

      before do
        create(:chain)
        create_list(:ticket, 2, user:)
        create(:ribon_config, default_ticket_value: 100)
        allow(Tickets::Donate).to receive(:call)
          .and_return(command_double(klass: Tickets::Donate, success: true, result: user.donations))
      end

      it 'calls the donate command with right params' do
        request

        expect(Tickets::Donate).to have_received(:call).with(
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

        expect_response_to_have_keys(%w[donations])
      end
    end
  end
end
