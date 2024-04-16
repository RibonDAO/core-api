module Api
  module V1
    module Payments
      class PixController < ApplicationController
        include ::Givings::Payment

        def create
          command = ::Givings::Payment::CreateOrder.call(OrderTypes::Pix, order_params)

          if command.success?
            Tracking::AddUtmJob.perform_later(utm_params:, trackable: command.result[:payment])
            render json: command.result, status: :created
          else
            render_errors(command.errors)
          end
        end

        def generate
          command = ::Givings::Payment::GeneratePix.call(external_id: params[:id])

          if command.success?
            render json: command.result
          else
            render_errors(command.errors)
          end
        end

        def find
          command = ::Givings::Payment::FindPaymentIntent.call(external_id: params[:id])

          if command.success?
            render json: command.result
          else
            render_errors(command.errors)
          end
        end

        private

        def order_params
          {
            email:,
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
          current_user || User.find_by(email: payment_params[:email]) || User.create(email: payment_params[:email],
                                                                                     language: I18n.locale)
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
          current_user&.email || payment_params[:email]
        end

        def operation
          :create_intent
        end

        def payment_params
          params.permit(:email, :tax_id, :offer_id, :country, :city, :state, :integration_id,
                        :cause_id, :non_profit_id, :platform, :name)
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
