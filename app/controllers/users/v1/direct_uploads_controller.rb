module Users
  module V1
    class DirectUploadsController < ActiveStorage::DirectUploadsController
      protect_from_forgery with: :null_session

      MAX_FILE_SIZE = 5.megabytes

      def create
        unless file_valid?
          render json: { error: 'File is too big or wrong format' }, status: :unprocessable_entity
          return
        end
  
        blob = ActiveStorage::Blob.create_before_direct_upload!(filename: blob_args[:filename],
                                                                byte_size: blob_args[:byte_size],
                                                                checksum: blob_args[:checksum],
                                                                content_type: blob_args[:content_type])

        render json: direct_upload_json(blob)
      end

      private

      def blob_args
        params.require(:blob).permit(:filename, :byte_size, :checksum, :content_type,
                                     :metadata)
      end

      def direct_upload_json(blob)
        blob.as_json(root: false, methods: :signed_id).merge(service_url: url_for(blob))
            .merge(direct_upload: {
                     url: blob.service_url_for_direct_upload,
                     headers: blob.service_headers_for_direct_upload
                   })
      end

      def file_valid?
        blob_args[:byte_size].to_i <= MAX_FILE_SIZE && blob_args[:content_type].in?(%w[image/jpeg image/png])
      end
    end
  end
end
