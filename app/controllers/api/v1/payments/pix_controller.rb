module Api
  module V1
    module Payments
      class PixController < ApplicationController
        include ::Givings::Payment

        def create
          command = ::Givings::Payment::CreateOrder.call(OrderTypes::Pix, order_params)

          if command.success?
            head :created
          else
            render_errors(command.errors)
          end
        end

        private

        def order_params
          {
            email: payment_params[:email],
            name: payment_params[:name],
            offer:,
            operation:,
            payment_method: :pix,
            tax_id: payment_params[:tax_id],
            user: find_or_create_user,
            integration_id: payment_params[:integration_id],
            cause:,
            non_profit:,
            platform: payment_params[:platform]
          }
        end

        def find_or_create_user
          current_user || User.find_or_create_by(email: payment_params[:email], language: I18n.locale)
        end

        def offer
          @offer ||= Offer.find payment_params[:offer_id].to_i
        end

        def cause
          @cause ||= Cause.find payment_params[:cause_id].to_i if payment_params[:cause_id]
        end

        def non_profit
          @non_profit ||= NonProfit.find payment_params[:non_profit_id].to_i if payment_params[:non_profit_id]
        end

        def operation
          :create_intent
        end

        def payment_params
          params.permit(:email, :tax_id, :offer_id, :country, :city, :state, :integration_id,
                        :cause_id, :non_profit_id, :platform, :name)
        end
      end
    end
  end
end
