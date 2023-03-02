require 'rails_helper'

RSpec.describe 'Api::V1::News::Authors', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/api/v1/news/authors' }

    before do
      create_list(:author, 2)
    end

    it 'returns a list of authors' do
      request

      expect_response_collection_to_have_keys(%w[id name created_at updated_at])
    end

    it 'returns 2 authors' do
      request

      expect(response_json.count).to eq(2)
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/api/v1/news/authors/#{author.id}" }

    let(:author) { create(:author) }

    it 'returns the author' do
      request

      expect_response_to_have_keys(%w[id name created_at updated_at])
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/api/v1/news/authors', params: }

    let(:params) { name: 'Author Name' }

    it 'returns the created author' do
      request

      expect_response_to_have_keys(%w[id name created_at updated_at])
    end
  end

  describe 'PUT /update' do
    subject(:request) { put "/api/v1/news/authors/#{author.id}", params: }

    let(:author) { create(:author) }
    let(:params) { name: 'Author Name' }

    it 'returns the updated author' do
      request

      expect_response_to_have_keys(%w[id name created_at updated_at])
    end
  end
end
