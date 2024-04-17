module Api
  module V1
    module Tickets
      class CollectController < ApplicationController
        def collect_by_integration
          command = ::Tickets::CollectByIntegration.call(integration:, user:, platform:)

          if command.success?
            ::Tracking::AddUtmJob.perform_later(utm_params:, trackable: command.result)
            render json: { ticket: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        def collect_by_external_ids
          command = ::Tickets::CollectByExternalIds.call(integration:, user:, platform:,
                                                         external_ids: ticket_params[:external_ids])

          if command.success?
            ::Tracking::AddUtmJob.perform_later(utm_params:, trackable: command.result)
            render json: { ticket: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        def can_collect_by_integration
          unless user
            render json: { can_collect: true }, status: :ok
            return
          end
          command = ::Tickets::CanCollectByIntegration.call(integration:, user:)

          if command.success?
            render json: { can_collect: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        def can_collect_by_external_ids
          command = ::Tickets::CanCollectByExternalIds.call(external_ids: ticket_params[:external_ids])

          if command.success?
            render json: { can_collect: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        def can_collect_by_coupon_id
          command = ::Tickets::CanCollectByCouponId.call(coupon_id: ticket_params[:coupon_id],
                                                         user_id: user&.id)

          if command.success?
            render json: { can_collect: command.result }, status: :ok
          else
            render json: { can_collect: false, errors: command.errors }, status: :ok
          end
        end

        private

        def integration
          @integration ||= Integration.find_by_id_or_unique_address ticket_params[:integration_id]
        end

        def user
          @user ||= current_user || User.find_by(email: ticket_params[:email])
        end

        def platform
          @platform ||= ticket_params[:platform]
        end

        def ticket_params
          params.permit(:integration_id, :email, :platform, :coupon_id, external_ids: [])
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
