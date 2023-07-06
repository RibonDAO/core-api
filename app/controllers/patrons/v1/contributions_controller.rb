module Patrons
  module V1
    class ContributionsController < PatronsController
      def index
        @contributions = current_patron.contributions.order(created_at: :desc)

        render json: ContributionBlueprint.render(@contributions, view: :with_stats)
      end
    end
  end
end
