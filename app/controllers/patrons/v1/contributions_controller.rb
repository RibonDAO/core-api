module Patrons
  module V1
    class ContributionsController < PatronsController
      def index
        @contributions = current_patron.contributions

        render json: ContributionBlueprint.render(@contributions, view: :with_stats)
      end
    end
  end
end
