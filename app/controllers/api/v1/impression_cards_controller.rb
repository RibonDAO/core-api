module Api
  module V1
    class ImpressionCardsController < ApplicationController
      def show
        @impression_card = ImpressionCard.find(params[:id])

        render json: ImpressionCardBlueprint.render(@impression_card)
      end
    end
  end
end
