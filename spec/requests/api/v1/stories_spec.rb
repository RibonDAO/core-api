require 'rails_helper'

RSpec.describe 'Api::V1::StoriesController', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/api/v1/stories' }

    let(:non_profit) { create(:non_profit) }
    let(:story) { create(:story, non_profit_id: non_profit.id) }

    it 'returns a successful response' do
      request

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/api/v1/stories', params: }

    context 'with the right params' do
      let(:non_profit) { create(:non_profit) }
      let(:params) do
        {
          title: 'New story',
          description: 'New story description',
          position: '1',
          active: 'true'
        }
      end
      let!(:result) { create(:story, non_profit_id: non_profit.id) }

      before do
        mock_command(klass: Stories::CreateStory, result:)
        request
      end

      it 'creates a new story' do
        expect(Stories::CreateStory).to have_received(:call).with(strong_params(params))
      end

      it 'returns a single story' do
        request

        expect_response_to_have_keys(%w[id title description active image image_description position])
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
    subject(:request) { get "/api/v1/stories/#{story.id}" }

    let(:non_profit) { create(:non_profit) }
    let(:story) { create(:story, non_profit_id: non_profit.id) }

    it 'returns a successful response' do
      request

      expect(response).to have_http_status(:ok)
    end

    it 'returns a single story' do
      request

      expect_response_to_have_keys(%w[id title description active image image_description position])
    end
  end

  describe 'PUT /update' do
    subject(:request) { put "/api/v1/stories/#{story.id}", params: }

    let(:non_profit) { create(:non_profit) }
    let(:story) { create(:story, non_profit_id: non_profit.id) }

    context 'with the right params' do
      let(:params) do
        {
          id: story.id.to_s,
          title: 'New story',
          description: 'Updated story description',
          position: '1',
          active: 'true'
        }
      end
      let!(:result) { create(:story, non_profit_id: non_profit.id) }

      before do
        mock_command(klass: Stories::UpdateStory, result:)
        request
      end

      it 'updates a story' do
        expect(Stories::UpdateStory).to have_received(:call).with(strong_params(params))
      end

      it 'returns a single story' do
        request

        expect_response_to_have_keys(%w[id title description active image image_description position created_at
                                        updated_at])
      end
    end
  end

  describe 'DELETE /destroy' do
    subject(:request) { delete "/api/v1/stories/#{story.id}" }

    let(:non_profit) { create(:non_profit) }
    let(:story) { create(:story, non_profit_id: non_profit.id) }

    it 'returns a successful response' do
      request

      expect(response).to have_http_status(:no_content)
    end
  end
end
