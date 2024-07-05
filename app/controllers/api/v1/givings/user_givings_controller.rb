module Api
  module V1
    module Givings
      class UserGivingsController < ApplicationController
        def index
          @customer = Customer.find_by(email: current_user&.email || params[:email])
          render json: PersonPaymentBlueprint.render(givings)
        end

        private

        def givings
          @givings ||= PersonPayment.joins(:offer)
                                    .where(offers: { category: :direct_contribution })
                                    .where(person_payments: {
                                             status: %i[paid refunded refund_failed],
                                             payer: @customer
                                           })
                                    .where.not(person_payments: { receiver: nil })
        end
      end
    end
  end
end
