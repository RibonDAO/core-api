module Api
  module V1
    module Payments
      class CreditCardsController < ApplicationController
        include ::Givings::Payment

        def create
          command = ::Givings::Payment::CreateOrder.call(OrderTypes::CreditCard, order_params)

          if command.success?
            head :created
          else
            render_errors(command.errors)
          end
        end

        private

        def order_params
          {
            card:,
            email: payment_params[:email],
            offer:,
            operation:,
            payment_method: :credit_card,
            tax_id: payment_params[:tax_id],
            user: find_or_create_user,
          }
        end

        def card
          @card ||= CreditCard.from(payment_params[:card])
        end

        def find_or_create_user
          current_user || User.find_or_create_by(email: payment_params[:email])
        end

        def offer
          @offer ||= Offer.find payment_params[:offer_id].to_i
        end

        def operation
          return :subscribe if offer.subscription?

          :purchase
        end

        def payment_params
          params.permit(:email, :tax_id, :offer_id, :country, :city, :state,
                        card: %i[cvv number name expiration_month expiration_year])
        end
      end
    end
  end
end
