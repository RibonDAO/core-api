module Managers
  module V1
    module Configs
      class RibonConfigController < ManagersController
        def index
          @ribon_config = RibonConfig.all

          render json: RibonConfigBlueprint.render(@ribon_config)
        end

        def update
          command = RibonConfigs::UpdateRibonConfig.call(ribon_config_params)

          if command.success?

            render json: RibonConfigBlueprint.render(command.result), status: :ok

          else

            render_errors(command.errors)

          end
        end

        private

        def ribon_config_params
          params.permit(:id, :default_ticket_value)
        end
      end
    end
  end
end
