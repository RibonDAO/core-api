module Managers
  module V1
    class PoolsController < ManagersController
      def index
        @pools = Pool.all

        render json: PoolBlueprint.render(@pools, view: :manager)
      end
    end
  end
end
