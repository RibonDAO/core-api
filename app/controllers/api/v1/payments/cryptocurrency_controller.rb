module Api
  module V1
    module Payments
      class CryptocurrencyController < ApplicationController
        include ::Givings::Payment

        def create
          command = ::Givings::Payment::CreateOrder.call(OrderTypes::Cryptocurrency, order_params)

          if command.success?
            head :created
          else
            render_errors(command.errors)
          end
        end

        def update_treasure_entry_status
          blockchain_transaction = PersonBlockchainTransaction.find_by(
            transaction_hash: payment_params[:transaction_hash]
          )

          blockchain_transaction.update!(treasure_entry_status: payment_params[:status].to_sym)
        rescue StandardError => e
          render json: { error: e.message }, status: :unprocessable_entity
        end

        private

        def order_params
          {
            amount: payment_params[:amount],
            email: payment_params[:email],
            payment_method: :crypto,
            user: find_or_create_user,
            cause:,
            non_profit:,
            wallet_address: payment_params[:wallet_address],
            transaction_hash: payment_params[:transaction_hash],
            integration_id: payment_params[:integration_id]
          }
        end

        def cause
          @cause ||= Cause.find payment_params[:cause_id].to_i if payment_params[:cause_id]
        end

        def non_profit
          @non_profit ||= NonProfit.find payment_params[:non_profit_id].to_i if payment_params[:non_profit_id]
        end

        def find_or_create_user
          current_user || User.find_or_create_by(email: payment_params[:email])
        end

        def payment_params
          params.permit(:email, :amount, :transaction_hash, :status, :cause_id, :non_profit_id, :wallet_address,
                        :integration_id)
        end
      end
    end
  end
end
