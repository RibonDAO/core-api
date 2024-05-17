require 'rails_helper'

RSpec.describe 'Managers::V1::Tags', type: :request do
  describe 'GET /v1/tags' do
    subject(:request) { get url }

    let(:user) { create(:user) }
    let(:url) { '/managers/v1/tags' }
    let!(:active_tags) { create_list(:tag, 2, status: "active") }

    it 'returns all tags' do
      request

      expect(response_body.length).to eq 2
      response_body.each { |tag| expect(active_tags.pluck(:id)).to include(tag['id']) }
    end

    it 'returns all necessary keys' do
      request

      expect(response_json.first.keys)
        .to match_array %w[name status non_profits created_at id updated_at]
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/managers/v1/tags/#{tag.id}" }

    let(:tag) { create(:tag) }

    it 'returns a single tag' do
      request

      expect_response_to_have_keys(%w[id name status non_profits created_at updated_at])
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/managers/v1/tags', params: }

    context 'with the right params' do
      let(:params) do
        { name: 'tag 1', status: 'active', non_profit_tags_attributes: [{non_profit_id: create(:non_profit).id.to_s}]
            
         }
      end
      let(:result) { create(:tag) }

      before do
        mock_command(klass: Tags::UpsertTag, result:)
      end

      it 'calls the upsert command with right params' do
        request

        expect(Tags::UpsertTag).to have_received(:call).with(strong_params(params))
      end

      it 'returns a single tag' do
        request

        expect_response_to_have_keys(%w[id name status non_profits created_at updated_at])
      end
    end
  end

  describe 'PUT /update' do
    context 'with the right params' do
      subject(:request) { put "/managers/v1/tags/#{tag.id}", params: }

      let(:tag) { create(:tag) }
      let(:non_profit) { create(:non_profit) }
      let(:params) do
         { id: tag.id.to_s, name: "Tag 2", status: tag.status, non_profit_tags_attributes: [{non_profit_id: non_profit.id.to_s}]
            
         }
      end

      it 'calls the upsert command with right params' do
        allow(Tags::UpsertTag).to receive(:call).and_return(command_double(klass: Tags::UpsertTag,
                                                                               result: tag))
        request

        expect(Tags::UpsertTag).to have_received(:call).with(strong_params(params))
      end

      it 'updates the tag' do
        request

        expect(tag.reload.name).to eq('Tag 2')
      end
    end
  end
end
