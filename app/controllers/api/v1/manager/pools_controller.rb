module Api
  module V1
    module Manager
      class PoolsController < ApplicationController
        def index_manager
          @pools = Pool.all

          render json: PoolBlueprint.render(@pools, view: :manager)
        end
      end
    end
  end
end
