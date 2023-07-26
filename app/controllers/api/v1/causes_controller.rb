module Api
  module V1
    class CausesController < ApplicationController
      def index
        @causes = Cause.all.shuffle

        render json: CauseBlueprint.render(@causes, view: :data_and_images)
      end

      def free_donation_causes
        @causes = CauseQueries.new.active_with_pool_balance
        @random_causes = @causes.shuffle


        render json: CauseBlueprint.render(@random_causes, view: :data_and_images)
      end

      def create
        command = Causes::UpsertCause.call(cause_params)
        if command.success?
          render json: CauseBlueprint.render(command.result), status: :created
        else
          render_errors(command.errors)
        end
      end

      def show
        @cause = Cause.find cause_params[:id]

        render json: CauseBlueprint.render(@cause)
      end

      def update
        command = Causes::UpsertCause.call(cause_params)
        if command.success?
          render json: CauseBlueprint.render(command.result), status: :ok
        else
          render_errors(command.errors)
        end
      end

      private

      def cause_params
        params.permit(
          :id,
          :name,
          :cover_image,
          :main_image,
          :cover_image_description,
          :main_image_description,
          :active
        )
      end
    end
  end
end
