require 'rails_helper'

RSpec.describe 'Managers::V1::BigDonors', type: :request do
  describe 'GET /index' do
    subject(:request) { get '/managers/v1/big_donors' }

    before do
      create_list(:big_donor, 1)
    end

    it 'returns http success' do
      request

      expect(response).to have_http_status(:success)
      expect_response_collection_to_have_keys(%w[id name email])
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/managers/v1/big_donors/#{big_donor.id}" }

    let(:big_donor) { create(:big_donor) }

    it 'returns a single big_donor' do
      request

      expect_response_to_have_keys(%w[id name email])
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/managers/v1/big_donors', params: }

    context 'with the right params' do
      let(:params) { { name: 'New big donor', email: 'bigdonor@gmail.com' } }
      let(:result) { create(:big_donor) }

      before do
        mock_command(klass: BigDonors::CreateBigDonor, result:)
      end

      it 'calls the create command with right params' do
        request

        expect(BigDonors::CreateBigDonor).to have_received(:call).with(strong_params(params))
      end

      it 'returns a single donor' do
        request

        expect_response_to_have_keys(%w[id name email])
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
      subject(:request) { put "/managers/v1/big_donors/#{big_donor.id}", params: }

      let(:big_donor) { create(:big_donor) }
      let(:params) { { id: big_donor.id.to_s, name: 'New big donor' } }

      it 'calls the update command with right params' do
        allow(BigDonors::UpdateBigDonor).to receive(:call).and_return(
          command_double(
            klass: BigDonors::UpdateBigDonor,
            result: big_donor
          )
        )
        request

        expect(BigDonors::UpdateBigDonor).to have_received(:call).with(strong_params(params))
      end

      it 'returns a single donor' do
        request

        expect_response_to_have_keys(%w[id name email])
      end

      it 'changes the name' do
        request

        expect(big_donor.reload.name).to eq('New big donor')
      end
    end
  end
end
