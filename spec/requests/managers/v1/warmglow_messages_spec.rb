require 'rails_helper'

RSpec.describe 'Managers::V1::WarmglowMessages', type: :request do
  describe 'GET /v1/warmglow_messages' do
    subject(:request) { get url }

    let(:user) { create(:user) }
    let(:url) { '/managers/v1/warmglow_messages' }
    let!(:warmglow_messages) { create_list(:warmglow_message, 2, status: 'active', message: 'message') }

    it 'returns all warmglow_messages' do
      request

      expect(response_body.length).to eq 2
      response_body.each do |warmglow_message|
        expect(warmglow_messages.pluck(:id)).to include(warmglow_message['id'])
      end
    end

    it 'returns all necessary keys' do
      request

      expect(response_json.first.keys)
        .to match_array %w[message status created_at id updated_at]
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/managers/v1/warmglow_messages/#{warmglow_message.id}" }

    let(:warmglow_message) { create(:warmglow_message) }

    it 'returns a single warmglow message' do
      request

      expect_response_to_have_keys(%w[id message status created_at updated_at])
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/managers/v1/warmglow_messages', params: }

    context 'with the right params' do
      let(:params) do
        { message: 'message 1', status: 'active' }
      end
      let(:result) { create(:warmglow_message) }

      before do
        mock_command(klass: WarmglowMessages::UpsertWarmglowMessage, result:)
      end

      it 'calls the upsert command with right params' do
        request

        expect(WarmglowMessages::UpsertWarmglowMessage).to have_received(:call).with(strong_params(params))
      end

      it 'returns a single warmglow message' do
        request

        expect_response_to_have_keys(%w[id message status created_at updated_at])
      end
    end
  end

  describe 'PUT /update' do
    context 'with the right params' do
      subject(:request) { put "/managers/v1/warmglow_messages/#{warmglow_message.id}", params: }

      let(:warmglow_message) { create(:warmglow_message) }
      let(:non_profit) { create(:non_profit) }
      let(:params) do
        { id: warmglow_message.id.to_s, message: 'message 2', status: warmglow_message.status }
      end

      it 'calls the upsert command with right params' do
        allow(WarmglowMessages::UpsertWarmglowMessage).to receive(:call)
          .and_return(command_double(klass: WarmglowMessages::UpsertWarmglowMessage,
                                     result: warmglow_message))
        request

        expect(WarmglowMessages::UpsertWarmglowMessage).to have_received(:call).with(strong_params(params))
      end

      it 'updates the warmglow message' do
        request

        expect(warmglow_message.reload.message).to eq('message 2')
      end
    end
  end
end
