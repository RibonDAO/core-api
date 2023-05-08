require 'rails_helper'

RSpec.describe 'Api::V1::Causes', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/api/v1/causes' }

    let!(:cause) { create(:cause) }
    let(:pool) { create(:pool, cause:) }
    let(:pool_balance) { create(:pool_balance, pool:, balance: 0) }

    before do
      create(:cause)
    end

    it 'returns a list of causes' do
      request

      expect_response_collection_to_have_keys(%w[created_at id updated_at name main_image cover_image pools
                                                 active non_profits default_pool cover_image_description
                                                 main_image_description])
    end

    it 'returns 2 causes' do
      request

      expect(response_json.count).to eq(2)
    end
  end

  describe 'GET /free_donation_causes' do
    subject(:request) { get '/api/v1/free_donation_causes' }

    let(:cause) { create(:cause) }
    let(:pool)  { create(:pool, cause:) }
    let(:pool_balance) { create(:pool_balance, pool:, balance: 0) }

    before do
      create(:chain)
      create(:ribon_config)

      create(:cause)
    end

    it 'returns a list of available causes for free donations' do
      request

      expect_response_collection_to_have_keys(%w[created_at id updated_at name main_image cover_image pools
                                                 active non_profits default_pool cover_image_description
                                                 main_image_description])
    end

    it 'returns 1 cause' do
      request

      expect(response_json.count).to eq(1)
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/api/v1/causes/#{cause.id}" }

    let(:cause) { create(:cause) }

    it 'returns a single causes' do
      request

      expect_response_to_have_keys(%w[created_at id updated_at name cover_image main_image pools active
                                      non_profits default_pool cover_image_description main_image_description])
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/api/v1/causes', params: }

    context 'with the right params' do
      let(:params) { { name: 'New Cause' } }
      let(:result) { create(:cause) }

      before do
        mock_command(klass: Causes::UpsertCause, result:)
      end

      it 'calls the upsert command with right params' do
        request

        expect(Causes::UpsertCause).to have_received(:call).with(strong_params(params))
      end

      it 'returns a single causes' do
        request

        expect_response_to_have_keys(%w[created_at id updated_at name cover_image main_image pools active
                                        non_profits default_pool cover_image_description main_image_description])
      end
    end

    context 'with the wrong params' do
      let(:params) { { name: '' } }

      it 'renders a error message' do
        request
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'PUT /update' do
    context 'with the right params' do
      subject(:request) { put "/api/v1/causes/#{cause.id}", params: }

      let(:cause) { create(:cause) }
      let(:params) { { id: cause.id.to_s, name: 'New Name' } }

      it 'calls the upsert command with right params' do
        allow(Causes::UpsertCause).to receive(:call).and_return(command_double(klass: Causes::UpsertCause,
                                                                               result: cause))
        request

        expect(Causes::UpsertCause).to have_received(:call).with(strong_params(params))
      end

      it 'updates the cause' do
        request

        expect(cause.reload.name).to eq('New Name')
      end
    end

    context 'with the wrong params' do
      subject(:request) { put '/api/v1/causes/abc', params: }

      let(:params) { { id: 'abc', name: '' } }

      it 'renders a error message' do
        request
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end
end
