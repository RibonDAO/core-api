module Users
  module V1
    module Tickets
      class CollectController < AuthorizationController
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

        def collect_by_club
          command = ::Tickets::CollectByClub.call(user:, platform:, category: ticket_params[:category])

          if command.success?
            render json: { tickets: command.result }, status: :ok
          else
            render_errors(command.errors)
          end
        end

        def collect_by_coupon_id
          command = ::Tickets::CollectByCouponId.call(user:, platform:,
                                                      coupon_id: ticket_params[:coupon_id])

          if command.success?
            tickets = command.result[:tickets]
            tickets.each do |ticket|
              ::Tracking::AddUtmJob.perform_later(utm_params:, trackable: ticket)
            end
            render json: command.result, status: :ok
          else
            render_errors(command.errors)
          end
        end

        private

        def integration
          @integration ||= Integration.find_by_id_or_unique_address ticket_params[:integration_id]
        end

        def user
          current_user
        end

        def platform
          @platform ||= ticket_params[:platform]
        end

        def ticket_params
          params.permit(:integration_id, :platform, :category, :coupon_id, external_ids: [])
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
