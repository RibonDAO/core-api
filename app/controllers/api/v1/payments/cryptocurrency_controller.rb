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
            transaction_hash: payment_params[:transaction_hash]
          }
        end

        def find_or_create_user
          current_user || User.find_or_create_by(email: payment_params[:email])
        end

        def payment_params
          params.permit(:email, :amount, :transaction_hash, :status)
        end
      end
    end
  end
end
