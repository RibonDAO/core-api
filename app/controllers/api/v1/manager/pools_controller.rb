module Api
  module V1
    module Manager
      class PoolsController < ApplicationController
        def index
          @pools = Pool.all

          render json: PoolBlueprint.render(@pools, view: :manager)
        end
      end
    end
  end
end
