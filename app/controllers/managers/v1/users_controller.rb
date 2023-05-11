module Managers
  module V1
    class UsersController < ManagersController
      def search
        @user = User.find_by(email: params[:email])

        if @user
          render json: UserBlueprint.render(@user, view: :extended)
        else
          render json: { error: 'user not found' }, status: :not_found
        end
      end

      def create
        @user = User.new(user_params)

        if @user.save
          render json: UserBlueprint.render(@user), status: :created
        else
          head :unprocessable_entity
        end
      end

      private

      def voucher
        @voucher ||= Voucher.new(external_id: params[:voucher_id],
                                 integration_id: params[:integration_id])
      end

      def user_params
        params.permit(:email, :language, :platform)
      end
    end
  end
end
