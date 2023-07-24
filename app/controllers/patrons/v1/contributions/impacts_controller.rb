module Patrons
  module V1
    module Contributions
      class ImpactsController < PatronsController
        before_action :set_contribution

        def index
          impact = Contributions::DirectImpact.new(contribution: @contribution).impact

          render json: ContributionDirectImpactBlueprint.render(impact)
        end

        private

        def set_contribution
          @contribution = current_patron.contributions.find(params[:contribution_id])
        end
      end
    end
  end
end
