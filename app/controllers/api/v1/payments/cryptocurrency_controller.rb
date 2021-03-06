module Api
  module V1
    module Payments
      class CryptocurrencyController < ApplicationController
        include ::Givings::Payment::OrderTypes

        def create
          command = ::Givings::Payment::CreateOrder.call(Cryptocurrency, order_params)

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
          Adapter::Controllers::Payment::Cryptocurrencies
            .new(payment_params:, user: current_user).order_params
        end

        def payment_params
          params.permit(:email, :amount, :transaction_hash, :status)
        end
      end
    end
  end
end
