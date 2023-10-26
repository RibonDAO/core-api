module Api
  module V1
    class ImpressionCardsController < ApplicationController
      def show
        @impression_card = ImpressionCard.find_by(id: params[:id], active: true)

        if(@impression_card)
          render json: ImpressionCardBlueprint.render(@impression_card)
        else
          render json: { error: 'Impression card not found' }, status: :not_found
        end
      end
    end
  end
end
