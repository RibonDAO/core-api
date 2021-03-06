require 'rails_helper'

RSpec.describe 'Api::V1::Payments::CreditCards', type: :request do
  let(:params) do
    { email: 'user@test.com', tax_id: '111.111.111-11', offer_id: offer.id,
      country: 'Brazil', city: 'Brasilia', state: 'DF',
      card: { cvv: 555, number: '4222 2222 2222 2222', name: 'User Test',
              expiration_month: '05', expiration_year: '25' } }
  end
  let(:create_order_command_double) do
    command_double(klass: ::Givings::Payment::CreateOrder)
  end
  let(:offer) { create(:offer) }
  let(:credit_card_double) do
    CreditCard.new(cvv: params[:card][:cvv], number: params[:card][:number], name: params[:card][:name],
                   expiration_month: params[:card][:expiration_month],
                   expiration_year: params[:card][:expiration_year])
  end
  let(:user_double) { build(:user, email: 'user@test.com') }

  let(:order_type) { ::Givings::Payment::OrderTypes::CreditCard }

  before do
    allow(::Givings::Payment::CreateOrder)
      .to receive(:call).and_return(create_order_command_double)
    allow(CreditCard).to receive(:new).and_return(credit_card_double)
    allow(User).to receive(:find_or_create_by).and_return(user_double)
  end

  describe 'POST /credit_cards' do
    subject(:request) { post '/api/v1/payments/credit_cards', params: }

    context 'when the command is successful' do
      let(:create_order_command_double) do
        command_double(klass: ::Givings::Payment::CreateOrder, success: true)
      end

      it 'returns http status created' do
        request

        expect(response).to have_http_status :created
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

      it 'calls the CreateOrder command with right params' do
        request
        expected_payload = { card: credit_card_double, email: 'user@test.com', tax_id: '111.111.111-11',
                             offer:, operation: :subscribe, payment_method: :credit_card,
                             user: user_double }

        expect(::Givings::Payment::CreateOrder).to have_received(:call).with(order_type, expected_payload)
      end
    end

    context 'when the offer is a purchase' do
      let(:offer) { create(:offer, subscription: false) }

      it 'calls the CreateOrder command with right params' do
        request
        expected_payload = { card: credit_card_double, email: 'user@test.com', tax_id: '111.111.111-11',
                             offer:, operation: :purchase, payment_method: :credit_card,
                             user: user_double }

        expect(::Givings::Payment::CreateOrder).to have_received(:call).with(order_type, expected_payload)
      end
    end
  end
end
