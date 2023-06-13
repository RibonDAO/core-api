module Api
  module V1
    module Givings
      class UserGivingsController < ApplicationController
        def index
          @customer = Customer.find_by(email: params[:email])
          render json: PersonPaymentBlueprint.render(givings)
        end

        private

        def givings
          @givings ||= PersonPayment.where(status: %i[paid refunded refund_failed], payer: @customer)
        end
      end
    end
  end
end
