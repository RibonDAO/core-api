require 'rails_helper'

RSpec.describe 'Managers::V1::WarmglowMessages', type: :request do
  describe 'GET /v1/warmglow_messages' do
    subject(:request) { get url }

    let(:user) { create(:user) }
    let(:url) { '/managers/v1/warmglow_messages' }
    let!(:active_warmglow_messages) { create_list(:warmglow_message, 2, status: 'active', message: 'message') }

    it 'returns all warmglow_messages' do
      request

      expect(response_body.length).to eq 2
      response_body.each do |warmglow_message|
        expect(active_warmglow_messages.pluck(:id)).to include(warmglow_message['id'])
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
end
