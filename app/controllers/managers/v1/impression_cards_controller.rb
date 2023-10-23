module Managers
  module V1
    class ImpressionCardsController < ManagersController
      def index
        @impression_cards = ImpressionCard.all

        render json: ImpressionCardBlueprint.render(@impression_cards)
      end

      def create
        @impression_card = ImpressionCard.new(impression_card_params)

        if @impression_card.save
          render json: ImpressionCardBlueprint.render(@impression_card), status: :created
        else
          head :unprocessable_entity
        end
      end

      def show
        @impression_card = ImpressionCard.find(params[:id])

        render json: ImpressionCardBlueprint.render(@impression_card)
      end

      def update
        @impression_card = ImpressionCard.find(params[:id])

        if @impression_card.update(impression_card_params)
          render json: ImpressionCardBlueprint.render(@impression_card), status: :ok
        else
          head :unprocessable_entity
        end
      end

      def destroy
        @impression_card = ImpressionCard.find(params[:id])

        if @impression_card.destroy
          head :no_content
        else
          head :unprocessable_entity
        end
      end

      private

      def impression_card_params
        params.permit(:id, :title, :headline, :description, :video_url, :cta_text, :cta_url, :image, :client,
                      :active)
      end
    end
  end
end
