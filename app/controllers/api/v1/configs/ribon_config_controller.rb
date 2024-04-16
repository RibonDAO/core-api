module Api
  module V1
    module Configs
      class RibonConfigController < ApplicationController
        def index
          @ribon_config = RibonConfig.all

          render json: RibonConfigBlueprint.render(@ribon_config)
        end
      end
    end
  end
end
