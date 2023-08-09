require 'rails_helper'

RSpec.describe 'Webhooks::Alchemy', type: :request do
  describe '/webhooks/alchemy' do
    subject(:request) do
      post '/webhooks/alchemy', params: event_params, headers: { 'X-Alchemy-Signature': alchemy_signature }
    end

    let(:event_params) do
      Rails.root.join('spec/support/webhooks/alchemy/dropped.json').read
    end

    context 'when it is not a request from alchemy' do
      let(:alchemy_signature) { nil }

      it 'returns :forbidden' do
        request
        expect(response).to have_http_status :forbidden
      end
    end

    context 'when it is a request from alchemy' do
      let(:alchemy_signature) { 'dff35a8fce767c48dc2a8d6c983d867f8dfcfbcc92c18d15103eccd99c88b23e' }

      context 'when it is a dropped notification' do
        it 'updates the status of a blockchain transaction or a person payment transaction' do
          blockchain_transaction = create(
            :blockchain_transaction,
            transaction_hash: '0x5cae384413d28da53c50596144d15c78628154892f355de002537e2904a8c5af'
          )
          request
          expect(blockchain_transaction.reload.status).to eq('dropped')
        end

        it 'updates the status of a person blockchain transaction or a person payment transaction' do
          person_blockchain_transaction = create(
            :person_blockchain_transaction,
            transaction_hash: '0x5cae384413d28da53c50596144d15c78628154892f355de002537e2904a8c5af'
          )
          request
          expect(person_blockchain_transaction.reload.treasure_entry_status).to eq('dropped')
        end
      end
    end
  end
end
