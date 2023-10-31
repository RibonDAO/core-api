module Users
  module V1
    class StatisticsController < AuthorizationController
      def index
        command = ::Users::CalculateStatistics.call(user:, wallet_address:, customer:, donations:)
        if command.success?
          render json: UserStatisticsBlueprint.render(command.result)
        else
          render_errors(command.errors)
        end
      end

      private

      def user
        current_user
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
