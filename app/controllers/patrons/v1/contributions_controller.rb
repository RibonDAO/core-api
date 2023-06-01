module Patrons
  module V1
    class ContributionsController < PatronsController
      def index
        @contributions = current_patron.contributions

        render json: ContributionBlueprint.render(@contributions)
      end
    end
  end
end
