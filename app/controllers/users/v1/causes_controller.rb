module Users
  module V1
    class CausesController < AuthorizationController
      def index
        @causes = if current_user&.email&.include?('@ribon.io')
                    active_and_test_causes
                  else
                    active_causes
                  end

        render json: CauseBlueprint.render(@causes, view: :data_and_images)
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

      def active_causes
        Cause.where(status: :active).where(id: Cause.select(:id)
                      .joins(:non_profits).where(non_profits: { status: 1 })).shuffle
      end

      def active_and_test_causes
        Cause.where(status: %i[active test]).where(id: Cause.select(:id)
                         .joins(:non_profits).where(non_profits: { status: %i[active test] })).shuffle
      end

      def cause_params
        params.permit(
          :id,
          :name,
          :cover_image,
          :main_image,
          :cover_image_description,
          :main_image_description,
          :status
        )
      end
    end
  end
end
