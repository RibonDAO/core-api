require 'rails_helper'

RSpec.describe 'Api::V1::Payments::StoresController', type: :request do
  let(:offer) { create(:offer) }
  let(:integration) { create(:integration) }
  let(:cause) { nil }
  let(:non_profit) { nil }
  let(:params) do
    { email: 'user@test.com', tax_id: '111.111.111-11', offer_id: offer.id,
      external_id: 'pi_123', country: 'Brazil', city: 'Brasilia', state: 'DF',
      integration_id: integration.id, cause_id: cause&.id, non_profit_id: non_profit&.id,
      payment_method_id:, payment_method_type:, name: 'name',
      utm_source: 'utm source',
      utm_medium: 'utm medium',
      utm_campaign: 'utm campaign' }
  end
  let(:payment_method_id) { 'pm_123' }
  let(:payment_method_type) { 'google_pay' }
  let(:create_order_command_double) do
    command_double(klass: ::Givings::Payment::CreateOrder)
  end

  let(:user_double) { build(:user, email: 'user@test.com') }

  let(:order_type) { ::Givings::Payment::OrderTypes::StorePay }

  before do
    allow(::Givings::Payment::CreateOrder)
      .to receive(:call).and_return(create_order_command_double)
    allow(User).to receive(:find_or_create_by).and_return(user_double)
  end

  describe 'POST /store_pay' do
    subject(:request) { post '/api/v1/payments/store_pay', params: }

    context 'when the command is successful' do
      let(:create_order_command_double) do
        command_double(klass: ::Givings::Payment::CreateOrder, success: true)
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

    context 'when the offer is a subscription' do
      let(:offer) { create(:offer, subscription: true) }
      let(:integration) { create(:integration) }

      it 'calls the CreateOrder command with right params' do
        request
        expected_payload = { email: 'user@test.com', tax_id: '111.111.111-11', payment_method_type:,
                             payment_method_id:, offer:, operation: :subscribe, non_profit:, name: 'name',
                             integration_id: integration.id.to_s, user: user_double, cause: }

        expect(::Givings::Payment::CreateOrder).to have_received(:call).with(order_type, expected_payload)
      end
    end

    context 'when the offer is a purchase' do
      let(:offer) { create(:offer, subscription: false) }
      let(:integration) { create(:integration) }

      it 'calls the CreateOrder command with right params' do
        request
        expected_payload = { email: 'user@test.com', tax_id: '111.111.111-11', payment_method_id:,
                             offer:, payment_method_type:, operation: :purchase, non_profit:, name: 'name',
                             integration_id: integration.id.to_s, user: user_double, cause: }

        expect(::Givings::Payment::CreateOrder).to have_received(:call).with(order_type, expected_payload)
      end
    end
  end
end
