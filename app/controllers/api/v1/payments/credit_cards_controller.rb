module Api
  module V1
    module Payments
      class CreditCardsController < ApplicationController
        include ::Givings::Payment

        before_action :ensure_account_confirmed, only: [:create]

        def create
          command = ::Givings::Payment::CreateOrder.call(OrderTypes::CreditCard, order_params)

          if command.success?
            Tracking::AddUtmJob.perform_later(utm_params:, trackable: command.result[:payment])
            head :created
          else
            render_errors(command.errors)
          end
        end

        def refund
          command = ::Givings::Payment::CreditCardRefund.call(external_id: params[:external_id])

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
            email:,
            offer:,
            operation:,
            payment_method: :credit_card,
            tax_id: payment_params[:tax_id],
            user: find_or_create_user,
            integration_id: payment_params[:integration_id],
            cause:,
            non_profit:,
            platform: payment_params[:platform]
          }
        end

        def card
          @card ||= CreditCard.from(payment_params[:card])
        end

        def find_or_create_user
          current_user
        end

        def ensure_account_confirmed
          head :unauthorized unless current_user.accounts.any? { |account| account.confirmed_at.present? }
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

        def email
          @email ||= current_user&.email || payment_params[:email]
        end

        def operation
          return :subscribe if offer.subscription?

          :purchase
        end

        def payment_params
          params.permit(:email, :tax_id, :offer_id, :country, :city, :state, :integration_id,
                        :cause_id, :non_profit_id,
                        :platform, card: %i[cvv number name expiration_month expiration_year])
        end

        def utm_params
          params.permit(:utm_source,
                        :utm_medium,
                        :utm_campaign)
        end
      end
    end
  end
end
