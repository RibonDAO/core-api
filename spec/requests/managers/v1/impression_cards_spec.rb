require 'rails_helper'

RSpec.describe 'Managers::V1::ImpressionCardsController', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/managers/v1/impression_cards' }

    let(:impression_card) { create(:impression_card) }

    it 'returns a successful response' do
      request

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/managers/v1/impression_cards', params: }

    context 'with the right params' do
      let(:params) do
        {
          title: 'New impression card',
          headline: 'New impression card headline',
          description: 'New impression card description',
          cta_text: 'New impression card cta text',
          cta_url: 'New impression card cta url'
        }
      end

      it 'creates a new impression card' do
        expect { request }.to change(ImpressionCard, :count).by(1)
      end

      it 'returns a single impression card' do
        request

        expect_response_to_have_keys(%w[id title headline description cta_text cta_url video_url image with_video])
      end
    end

    context 'with the wrong params' do
      let(:params) { { title: '' } }

      it 'renders a error message' do
        request
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/managers/v1/impression_cards/#{impression_card.id}" }

    let(:impression_card) { create(:impression_card) }

    it 'returns a single impression card' do
      request

      expect_response_to_have_keys(%w[id title headline description cta_text cta_url video_url image with_video])
    end
  end

  describe 'PUT /update' do
    subject(:request) { put "/managers/v1/impression_cards/#{impression_card.id}", params: }

    let(:impression_card) { create(:impression_card) }

    context 'with the right params' do
      let(:params) do
        {
          title: 'New impression card',
          headline: 'New impression card headline',
          description: 'New impression card description',
          cta_text: 'New impression card cta text',
          cta_url: 'New impression card cta url'
        }
      end

      it 'updates the impression card' do
        request

        expect(impression_card.reload.title).to eq('New impression card')
        expect(impression_card.reload.headline).to eq('New impression card headline')
        expect(impression_card.reload.description).to eq('New impression card description')
        expect(impression_card.reload.cta_text).to eq('New impression card cta text')
        expect(impression_card.reload.cta_url).to eq('New impression card cta url')
      end

      it 'returns a single impression card' do
        request

        expect_response_to_have_keys(%w[id title headline description cta_text cta_url video_url image with_video])
      end
    end
  end

  describe 'DELETE /destroy' do
    subject(:request) { delete "/managers/v1/impression_cards/#{impression_card.id}" }

    let!(:impression_card) { create(:impression_card) }

    it 'deletes the impression card' do
      expect { request }.to change(ImpressionCard, :count).by(-1)
    end
  end
end
