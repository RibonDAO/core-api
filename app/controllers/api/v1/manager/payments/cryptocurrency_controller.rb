module Api
  module V1
    module Manager
      module Payments
        class CryptocurrencyController < ApplicationController
          include ::Manager::Payments

          def create_big_donation
            command = ::Manager::Payments::Cryptocurrency.call(big_donation_params)

            if command.success?
              head :created
            else
              render_errors(command.errors)
            end
          end

          private

          def big_donation_params
            {
              amount: payment_params[:amount],
              payer: big_donor,
              receiver: cause,
              transaction_hash: payment_params[:transaction_hash],
              integration_id: payment_params[:integration_id]
            }
          end

          def cause
            Cause.find_by(id: payment_params[:cause_id].to_i) if payment_params[:cause_id]
          end

          def big_donor
            BigDonor.find_by(id: payment_params[:big_donor_id]) if payment_params[:big_donor_id]
          end

          def payment_params
            params.permit(:amount, :transaction_hash, :status, :cause_id, :big_donor_id,
                          :integration_id)
          end
        end
      end
    end
  end
end
