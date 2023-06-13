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
      { big_donor_id: 1, cause_id: 1, integration_id: 1,
        transaction_hash: '0xFFFF', amount: '5.00', feeable: }
    end
    let(:feeable) { nil }

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

    context 'when feeable param is empty' do
      it 'calls the Manager::Payments::Cryptocurrency command with CreateContribution param' do
        request

        expect(::Manager::Payments::Cryptocurrency)
          .to have_received(:call).with({ amount: params[:amount], payer: nil, receiver: nil,
                                          transaction_hash: params[:transaction_hash],
                                          integration_id: params[:integration_id].to_s,
                                          create_contribution_command: Contributions::CreateContribution })
      end
    end

    context 'when feeable param is false' do
      let(:feeable) { false }

      it 'calls the Manager::Payments::Cryptocurrency command with CreateNonFeeableContribution param' do
        request

        expect(::Manager::Payments::Cryptocurrency)
          .to have_received(:call)
          .with({ amount: params[:amount], payer: nil, receiver: nil,
                  transaction_hash: params[:transaction_hash], integration_id: params[:integration_id].to_s,
                  create_contribution_command: Contributions::CreateNonFeeableContribution })
      end
    end

    context 'when feeable param is true' do
      let(:feeable) { true }

      it 'calls the Manager::Payments::Cryptocurrency command with CreateContribution param' do
        request

        expect(::Manager::Payments::Cryptocurrency)
          .to have_received(:call)
          .with({ amount: params[:amount], payer: nil, receiver: nil,
                  transaction_hash: params[:transaction_hash], integration_id: params[:integration_id].to_s,
                  create_contribution_command: Contributions::CreateContribution })
      end
    end
  end
end
