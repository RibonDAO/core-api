require 'rails_helper'

RSpec.describe 'Api::V1::Manager::Payments::Cryptocurrency', type: :request do
  let(:create_order_command_double) do
    command_double(klass: ::Manager::Payments::Cryptocurrency)
  end

  before do
    allow(::Manager::Payments::Cryptocurrency)
      .to receive(:call).and_return(create_order_command_double)
  end

  describe 'POST /cryptocurrency' do
    subject(:request) { post '/api/v1/manager/payments/cryptocurrency/big_donation', params: }

    let(:params) do
      { big_donor_id: 1, cause_id: 1, integration_id: 1, transaction_hash: '0xFFFF', amount: '5.00' }
    end

    context 'when the command is successful' do
      let(:create_order_command_double) do
        command_double(klass: ::Manager::Payments::Cryptocurrency, success: true)
      end

      it 'returns http status created' do
        request

        expect(response).to have_http_status :created
      end
    end

    context 'when the command is failure' do
      let(:create_order_command_double) do
        command_double(klass: ::Manager::Payments::Cryptocurrency, success: false, failure: true)
      end

      it 'returns http status created' do
        request

        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
