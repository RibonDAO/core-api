module Api
  module V1
    class ChainsController < ApplicationController
      def index
        @chains = Chain.all

        render json: ChainBlueprint.render(@chains)
      end
    end
  end
end
