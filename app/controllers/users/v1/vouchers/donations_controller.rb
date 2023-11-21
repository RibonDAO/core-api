module Users
  module V1
    module Vouchers
      class DonationsController < AuthorizationController
        def create
          command = ::Vouchers::Donate.call(donation_command:, integration:, external_id:)

          if command.success?
            Tracking::AddUtm.call(utm_params:, trackable: command.result.donation)
            render json: VoucherBlueprint.render(command.result), status: :created
          else
            render_errors(command.errors)
          end
        end

        private

        def integration
          @integration ||= Integration.find_by_id_or_unique_address donation_params[:integration_id]
        end

        def non_profit
          @non_profit ||= NonProfit.find donation_params[:non_profit_id]
        end

        def user
          current_user
        end

        def external_id
          @external_id ||= donation_params[:external_id]
        end

        def platform
          @platform ||= donation_params[:platform]
        end

        def donation_command
          ::Donations::Donate.new(integration:, non_profit:, user:, platform:, skip_allowance: true)
        end

        def donation_params
          params.permit(:integration_id, :non_profit_id, :email, :external_id, :platform)
        end

        def utm_params
          params.permit(:utm_source,
                        :utm_medium,
                        :utm_campaign)
        end
      end
    end
  end
end
