require 'rails_helper'

RSpec.describe 'Api::V1::Payments::Pix', type: :request do
  let(:offer) { create(:offer) }
  let(:integration) { create(:integration) }
  let(:cause) { nil }
  let(:non_profit) { nil }
  let(:params) do
    { email: 'user@test.com', tax_id: '111.111.111-11', offer_id: offer.id, name: 'Test User',
      external_id: 'pi_123', country: 'Brazil', city: 'Brasilia', state: 'DF',
      integration_id: integration.id, cause_id: cause&.id, non_profit_id: non_profit&.id,
      platform: 'web',
      utm_source: 'utm source',
      utm_medium: 'utm medium',
      utm_campaign: 'utm campaign' }
  end
  let(:create_order_command_double) do
    command_double(klass: ::Givings::Payment::CreateOrder, result: { payment: nil })
  end

  let(:user_double) { build(:user, email: 'user@test.com') }
  let(:order_type) { ::Givings::Payment::OrderTypes::Pix }

  before do
    allow(::Givings::Payment::CreateOrder)
      .to receive(:call).and_return(create_order_command_double)
    allow(User).to receive(:find_by).and_return(user_double)
  end

  describe 'POST /pix' do
    subject(:request) { post '/api/v1/payments/pix', params: }

    context 'when the command is successful' do
      let(:create_order_command_double) do
        command_double(klass: ::Givings::Payment::CreateOrder, success: true, result: { payment: nil })
      end

      before do
        allow(Tracking::AddUtm).to receive(:call)
      end

      it 'returns http status created' do
        request

        expect(response).to have_http_status :created
      end

      it 'calls add utm command' do
        request
        expect(Tracking::AddUtm).to have_received(:call)
      end
    end

    context 'when the command is failure' do
      let(:create_order_command_double) do
        command_double(klass: ::Givings::Payment::CreateOrder, success: false, failure: true)
      end

      it 'returns http status created' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end
    end

    context 'when the offer is a unique' do
      let(:offer) { create(:offer, subscription: false) }
      let(:integration) { create(:integration) }

      it 'calls the CreateOrder command with right params' do
        request
        expected_payload = { email: 'user@test.com', tax_id: '111.111.111-11', name: 'Test User',
                             offer:, operation: :create_intent, payment_method: :pix, non_profit:,
                             platform: 'web',
                             integration_id: integration.id.to_s, user: user_double, cause: }

        expect(::Givings::Payment::CreateOrder).to have_received(:call).with(order_type, expected_payload)
      end
    end

    context 'when there is a cause_id' do
      let(:offer) { create(:offer, subscription: false) }
      let(:integration) { create(:integration) }
      let(:cause) { create(:cause) }

      it 'calls the CreateOrder command with right params' do
        request
        expected_payload = { email: 'user@test.com', tax_id: '111.111.111-11', name: 'Test User',
                             offer:, operation: :create_intent, payment_method: :pix, non_profit:,
                             platform: 'web',
                             integration_id: integration.id.to_s, user: user_double, cause: }

        expect(::Givings::Payment::CreateOrder).to have_received(:call).with(order_type, expected_payload)
      end
    end

    context 'when there is a non_profit_id' do
      let(:offer) { create(:offer, subscription: false) }
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit) }

      it 'calls the CreateOrder command with right params' do
        request
        expected_payload = { email: 'user@test.com', tax_id: '111.111.111-11', name: 'Test User',
                             offer:, operation: :create_intent, payment_method: :pix, cause:,
                             platform: 'web',
                             integration_id: integration.id.to_s, user: user_double, non_profit: }

        expect(::Givings::Payment::CreateOrder).to have_received(:call).with(order_type, expected_payload)
      end
    end
  end
end
