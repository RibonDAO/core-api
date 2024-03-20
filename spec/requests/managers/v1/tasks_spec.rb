require 'rails_helper'

RSpec.describe 'Managers::V1::TasksController', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/managers/v1/tasks' }

    let(:task) { create(:task) }

    it 'returns a successful response' do
      request

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/managers/v1/tasks', params: }

    context 'with the right params' do
      let(:params) do
        {
          title: 'New task',
          actions: 'causes_page_view',
          type: 'daily',
          navigation_callback: 'https://www.google.com',
          visibility: 'visible',
          client: 'web'
        }
      end

      it 'creates a new impression card' do
        expect { request }.to change(Task, :count).by(1)
      end

      it 'returns a single impression card' do
        request

        expect_response_to_have_keys(%w[id title actions kind navigation_callback visibility client])
      end
    end

    context 'with the wrong params' do
      let(:params) { { title: '', actions: '' } }

      it 'renders a error message' do
        request
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/managers/v1/tasks/#{task.id}" }

    let(:task) { create(:task) }

    it 'returns a single impression card' do
      request

      expect_response_to_have_keys(%w[id title actions kind navigation_callback visibility client])
    end
  end

  describe 'PUT /update' do
    subject(:request) { put "/managers/v1/tasks/#{task.id}", params: }

    let(:task) { create(:task) }

    context 'with the right params' do
      let(:params) do
        {
          title: 'New task',
          actions: 'causes_page_view, payment_page_view',
          type: 'daily',
          navigation_callback: 'https://www.google.com',
          visibility: 'visible',
          client: 'web'
        }
      end

      it 'updates the impression card' do
        request

        expect(task.reload.title).to eq('New task')
        expect(task.reload.actions).to eq('causes_page_view, payment_page_view')
        expect(task.reload.kind).to eq('daily')
        expect(task.reload.navigation_callback).to eq('https://www.google.com')
        expect(task.reload.visibility).to eq('visible')
        expect(task.reload.client).to eq('web')
      end

      it 'returns a single impression card' do
        request

        expect_response_to_have_keys(%w[id title actions kind navigation_callback visibility client])
      end
    end
  end

  describe 'DELETE /destroy' do
    subject(:request) { delete "/managers/v1/tasks/#{task.id}" }

    let!(:task) { create(:task) }

    it 'deletes the impression card' do
      expect { request }.to change(Task, :count).by(-1)
    end
  end
end
