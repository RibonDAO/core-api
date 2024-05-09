module Api
  module V1
    module Users
      class StatisticsController < ApplicationController
        def index
          command = ::Users::CalculateStatistics.call(user:, wallet_address:, customer:, donations:)
          if command.success?
            render json: UserStatisticsBlueprint.render(command.result)
          else
            render_errors(command.errors)
          end
        end

        def donation_streak
          if user
            render json: { streak: user.donation_streak }
          else
            render json: { streak: 0 }
          end
        end

        private

        def user
          return unless params[:id] || current_user

          @user ||= current_user || User.find(params[:id])
        end

        def wallet_address
          return unless params[:wallet_address]

          Base64.strict_decode64(params[:wallet_address])
        end

        def customer
          return unless user

          Customer.find_by(email: user.email)
        end

        def donations
          return unless user

          @donations = user.donations
        end
      end
    end
  end
end
