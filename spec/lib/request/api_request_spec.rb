require 'rails_helper'

RSpec.describe Request::ApiRequest do
  describe '#get' do
    subject(:request) { described_class.get(url) }

    let(:url) { 'http://test.url' }
    let(:response_json) { { 'some_key' => 'value' }.to_json }
    let(:cached_response) { nil }

    before do
      allow(RedisStore::Cache).to receive(:find).and_return(cached_response)
      allow(HTTParty).to receive(:get).and_return(instance_double(HTTParty::Response, code: 200, body: response_json))
      allow(RedisStore::Cache).to receive(:find_or_create)
    end

    context 'when the response is not cached' do
      it 'calls HTTParty with get method and correct params' do
        request

        expect(HTTParty).to have_received(:get).with(url, headers: {})
      end

      it 'saves the response to cache' do
        request

        expect(RedisStore::Cache).to have_received(:find_or_create).with(key: url.parameterize, expires_in: nil)
      end

      it 'returns the correct response' do
        expect(JSON.parse(request.body)['some_key']).to eq 'value'
      end
    end

    context 'when the response is cached' do
      let(:cached_response) { response_json }

      it 'does not call HTTParty' do
        request

        expect(HTTParty).not_to have_received(:get)
      end

      it 'returns the cached response' do
        expect(JSON.parse(request)['some_key']).to eq 'value'
      end
    end

    context 'when the response code is not 200' do
      before do
        allow(HTTParty).to receive(:get).and_return(instance_double(HTTParty::Response, code: 500))
      end

      it 'does not save the response to cache' do
        request

        expect(RedisStore::Cache).not_to have_received(:find_or_create)
      end

      it 'returns the correct response' do
        expect(request.code).to eq 500
      end
    end
  end

  describe '#post' do
    subject(:request) { described_class.post(url, body:, headers:) }

    let(:url) { 'http://test.url' }
    let(:response_json) { { 'some_key' => 'value' }.to_json }
    let(:body) { { body_key: 'body value' }.to_json }
    let(:headers) { { 'some_header' => 'some header' } }
    let(:default_headers) { { 'Content-Type' => 'application/json' } }

    before do
      allow(HTTParty).to receive(:post).and_return(instance_double(HTTParty::Response, body: response_json))
    end

    it 'calls HTTParty with post method and correct params' do
      request

      expect(HTTParty).to have_received(:post).with(url, body:, headers: default_headers.merge(headers))
    end

    it 'returns the correct response' do
      expect(JSON.parse(request.body)['some_key']).to eq 'value'
    end
  end
end
