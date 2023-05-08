module Api
  module V1
    class NonProfitsController < ApplicationController
      def index
        @non_profits = NonProfit.where(status: :active).order(cause_id: :asc)

        render json: NonProfitBlueprint.render(@non_profits)
      end

      def free_donation_non_profits
        @non_profits = NonProfitQueries.new.active_with_pool_balance

        render json: NonProfitBlueprint.render(@non_profits)
      end

      def stories
        @non_profit = NonProfit.find(params[:id])
        @stories = @non_profit.stories.where(active: true).order(position: :asc)

        render json: StoryBlueprint.render(@stories, view: :minimal)
      end

      def create
        command = NonProfits::CreateNonProfit.call(non_profit_params)
        if command.success?
          render json: NonProfitBlueprint.render(command.result), status: :created
        else
          render_errors(command.errors)
        end
      end

      def show
        @non_profit = NonProfit.find_by fetch_non_profit_query

        render json: NonProfitBlueprint.render(@non_profit)
      end

      def update
        command = NonProfits::UpdateNonProfit.call(non_profit_params)
        if command.success?
          render json: NonProfitBlueprint.render(command.result), status: :ok
        else
          render_errors(command.errors)
        end
      end

      private

      def non_profit_params
        params.permit(:id, :name, :status, :impact_description, :wallet_address,
                      :logo, :main_image, :background_image, :confirmation_image, :cause_id,
                      stories_attributes: %i[id title description position active image],
                      non_profit_impacts_attributes: %i[id start_date end_date usd_cents_to_one_impact_unit
                                                        donor_recipient impact_description measurement_unit])
      end

      def fetch_non_profit_query
        uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

        return { unique_address: non_profit_params[:id] } if uuid_regex.match?(non_profit_params[:id])

        { id: non_profit_params[:id] }
      end
    end
  end
end
