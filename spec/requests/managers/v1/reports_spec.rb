require 'rails_helper'

RSpec.describe 'Mangers::V1::ReportsController', :report, type: :request do
  describe 'GET /index' do
    subject(:request) { get '/managers/v1/reports' }

    let(:report) { create(:report) }

    it 'returns a successfull response' do
      request

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /create' do
    subject(:request) { post '/managers/v1/reports', params: }

    context 'with the right params' do
      let(:params) do
        {
          name: 'New report',
          link: 'http://report.report.com',
          active: true
        }
      end

      it 'creates a new report' do
        expect { request }.to change(Report, :count).by(1)
      end

      it 'returns a single report' do
        request

        expect_response_to_have_keys(%w[id name link active])
      end
    end

    context 'with the wrong params' do
      let(:params) { { name: '', link: '', active: true } }

      it 'renders a error message' do
        request
        expect(response).to have_http_status :unprocessable_entity
      end
    end
  end

  describe 'GET /show' do
    subject(:request) { get "/managers/v1/reports/#{report.id}" }

    let(:report) { create(:report) }

    it 'returns a single report' do
      request

      expect_response_to_have_keys(%w[id name link active])
    end
  end

  describe 'PUT /update' do
    subject(:request) { put "/managers/v1/reports/#{report.id}", params: }

    let(:report) { create(:report) }

    context 'with the right params' do
      let(:params) do
        {
          name: 'New report',
          link: 'http://report.report.com',
          active: true
        }
      end

      it 'updates the report' do
        request

        expect(report.reload.name).to eq('New report')
        expect(report.reload.link).to eq('http://report.report.com')
        expect(report.reload.active).to eq(true)
      end

      it 'returns a single report' do
        request

        expect_response_to_have_keys(%w[id name link active])
      end
    end
  end

  describe 'DELTE /destroy' do
    subject(:request) { delete "/managers/v1/reports/#{report.id}" }

    let!(:report) { create(:report) }

    it 'delete the report' do
      expect { request }.to change(Report, :count).by(-1)
    end
  end
end