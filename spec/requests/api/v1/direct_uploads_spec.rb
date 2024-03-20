require 'rails_helper'

RSpec.describe 'Api::V1::DirectUploads', type: :request do
  describe 'POST /create' do
    subject(:request) { post '/api/v1/rails/active_storage/direct_uploads', params: }

    let(:params) do
      { blob: {
        filename: 'teste.jpeg',
        byte_size: 649_004,
        checksum: 'FN224+vkcKWKUQ0A2iVeTQ==',
        content_type: 'image/jpeg'
      } }
    end

    it 'creates a new blob on active storage' do
      request

      expect_response_to_have_keys(%w[attachable_sgid byte_size checksum content_type created_at direct_upload
                                      filename id key metadata service_name service_url signed_id])
    end
  end
end
