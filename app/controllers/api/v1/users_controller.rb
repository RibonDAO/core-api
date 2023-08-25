module Api
  module V1
    class UsersController < ApplicationController
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
          Tracking::AddUtm.call(utm_params:, trackable: @user)
          render json: UserBlueprint.render(@user), status: :created
        else
          head :unprocessable_entity
        end
      end

      def can_donate
        @integration = Integration.find_by_id_or_unique_address params[:integration_id]
        @platform = params[:platform]

        if voucher?
          render json: { can_donate: voucher&.valid? }
        elsif current_user
          render json: { can_donate: current_user.can_donate?(@integration, @platform),
                         donate_app: current_user.donate_app }
        else
          render json: { can_donate: true }
        end
      end

      def first_access_to_integration
        @integration = Integration.find_by_id_or_unique_address params[:integration_id]

        if current_user

          current_user.create_user_donation_stats! unless current_user.user_donation_stats

          first_access_to = current_user.user_last_donation_to(@integration).nil?

          render json: { first_access_to_integration: first_access_to }

        else

          render json: { first_access_to_integration: true }
        end
      end

      def completed_tasks
        if current_user
          render json: UserCompletedTaskBlueprint.render(current_user.user_completed_tasks)
        else
          render json: [], status: :not_found
        end
      end

      def complete_task
        if current_user
          task = ::Users::UpsertTask.call(user: current_user, task_identifier: params[:task_identifier]).result

          ::Users::IncrementStreak.call(user: current_user)
          render json: UserCompletedTaskBlueprint.render(task)
        else
          head :unauthorized
        end
      end

      def send_delete_account_email
        if current_user
          jwt = ::Jwt::Encoder.encode({ email: current_user.email })
          Mailers::SendUserDeletionEmailJob.perform_now(user: current_user, jwt:)

          render json: { sent: true }, status: :ok
        else
          head :unauthorized
        end
      end

      def destroy
        email = ::Jwt::Decoder.decode(token: params[:token]).first['email']
        return head :unauthorized unless email

        user = User.find_by(email:)
        command = ::Users::Anonymize.call(user)

        if command.success?
          head :ok
        else
          head :unprocessable_entity
        end
      rescue StandardError
        head :unauthorized
      end

      private

      def voucher?
        params[:voucher_id].present?
      end

      def voucher
        @voucher ||= Voucher.new(external_id: params[:voucher_id],
                                 integration_id: @integration&.id)
      end

      def user_params
        params.permit(:email, :language, :platform)
      end

      def utm_params
        params.permit(:utm_source,
                      :utm_medium,
                      :utm_campaign)
      end
    end
  end
end
