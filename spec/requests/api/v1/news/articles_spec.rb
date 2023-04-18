require 'rails_helper'

RSpec.describe 'Api::V1::News::Articles', type: :request do
  describe 'GET /index with 2 articles available' do
    subject(:request) { get '/api/v1/news/articles' }

    before do
      create_list(:article, 2, visible: true)
    end

    it 'returns a list of articles' do
      request

      expect_response_collection_to_have_keys(%w[author image_url created_at id published_at title updated_at
                                                 visible language link published_at_in_words])
    end

    it 'returns 2 articles' do
      request

      expect(response_json.count).to eq(2)
    end
  end

  describe 'GET /index with 1 article available' do
    subject(:request) { get '/api/v1/news/articles' }

    before do
      create(:article, visible: true)
      create_list(:article, 2, visible: false)
    end

    it 'returns 1 article' do
      request

      expect(response_json.count).to eq(1)
    end
  end

  describe 'GET /index when some articles are unpublished' do
    subject(:request) { get '/api/v1/news/articles' }

    before do
      create(:article, visible: true)
      create_list(:article, 2, visible: true, published_at: 1.day.from_now)
    end

    it 'returns 1 article' do
      request

      expect(response_json.count).to eq(1)
    end
  end

  describe 'GET /index with 2 hidden articles' do
    subject(:request) { get '/api/v1/news/articles?show_hidden_articles=true' }

    before do
      create_list(:article, 2, visible: false)
    end

    it 'returns 2 articles' do
      request

      expect(response_json.count).to eq(2)
    end
  end

  describe 'GET /index with an 8 items pagination' do
    subject(:request) { get '/api/v1/news/articles?page=1&per=8' }

    before do
      create_list(:article, 10, visible: true)
    end

    it 'returns 8 articles' do
      request

      expect(response_json.count).to eq(8)
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/api/v1/news/articles/#{article.id}" }

    let(:article) { create(:article, visible: true) }

    it 'returns a articles' do
      request

      expect_response_to_have_keys(%w[author image_url created_at id published_at title updated_at
                                      visible language link published_at_in_words])
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/api/v1/news/articles', params: article_params }

    let(:article_params) do
      {
        title: 'New Article',
        published_at: Time.zone.now,
        visible: true,
        author_id: create(:author).id,
        link: 'https://ribon.io',
        language: 'en-US'
      }
    end

    it 'creates a new articles' do
      request

      expect(Article.count).to eq(1)
    end
  end

  describe 'PUT /update' do
    subject(:request) { put "/api/v1/news/articles/#{article.id}", params: article_params }

    let(:article) { create(:article) }
    let(:article_params) do
      {
        title: 'New Article',
        published_at: Time.zone.now,
        visible: true,
        author_id: create(:author).id,
        link: 'https://ribon.io',
        language: 'pt-BR'
      }
    end

    it 'updates a articles' do
      request

      expect(Article.count).to eq(1)
      expect(Article.first.title).to eq('New Article')
      expect(Article.first.language).to eq('pt-BR')
    end
  end
end
