module Api
  module V1
    module Givings
      class FeesController < ApplicationController
        def card_fees
          command = ::Givings::Card::CalculateStripeGiving.call(value:,
                                                                currency:)

          if command.success?
            render json: GivingFeeBlueprint.render(command.result), status: :ok
          else
            render_errors(command.errors)
          end
        end

        private

        def value
          @value ||= params[:value].to_f
        end

        def currency
          @currency ||= params[:currency]&.downcase&.to_sym
        end
      end
    end
  end
end
