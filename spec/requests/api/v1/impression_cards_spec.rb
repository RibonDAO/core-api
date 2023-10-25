require 'rails_helper'

RSpec.describe 'Api::V1::ImpressionCards', type: :request do
  describe 'GET /show' do
    subject(:request) { get "/api/v1/impression_cards/#{impression_card.id}" }

    let(:impression_card) { create(:impression_card) }

    it 'returns a single impression card' do
      request

      expect_response_to_have_keys(%w[id title headline description cta_text cta_url video_url image with_video
                                      client active])
    end
  end
end
