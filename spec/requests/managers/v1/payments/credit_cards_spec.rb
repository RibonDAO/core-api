require 'rails_helper'

RSpec.describe 'Managers::V1::Payments::CreditCards', type: :request do
  let(:offer) { create(:offer) }
  let(:integration) { create(:integration) }
  let(:cause) { nil }
  let(:non_profit) { nil }
  let(:params) do
    { email: 'user@test.com', tax_id: '111.111.111-11', offer_id: offer.id,
      external_id: 'pi_123', country: 'Brazil', city: 'Brasilia', state: 'DF',
      integration_id: integration.id, cause_id: cause&.id, non_profit_id: non_profit&.id,
      card: { cvv: 555, number: '4222 2222 2222 2222', name: 'User Test',
              expiration_month: '05', expiration_year: '25' } }
  end
  let(:create_order_command_double) do
    command_double(klass: ::Givings::Payment::CreateOrder)
  end

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

  describe 'POST /credit_cards_refund' do
    subject(:request) { post '/managers/v1/payments/credit_cards_refund', params: }

    before do
      mock_command(klass: Givings::Payment::CreditCardRefund, result: true)
      request
    end

    it 'returns http status created' do
      request

      expect(response).to have_http_status :created
    end
  end
end
