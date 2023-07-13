module Api
  module V1
    module Givings
      class FeesController < ApplicationController
        def card_fees
          command = ::Givings::Card::CalculateCardGiving.call(value:, currency:, gateway:)

          if command.success?
            render json: GivingFeeBlueprint.render(formatted_result(command.result)), status: :ok
          else
            render_errors(command.errors)
          end
        end

        private

        def formatted_result(result)
          result.transform_values(&:format)
        end

        def value
          @value ||= params[:value].to_f
        end

        def currency
          @currency ||= params[:currency]&.downcase&.to_sym
        end

        def gateway
          @gateway ||= params[:gateway]&.downcase&.to_sym || :stripe
        end
      end
    end
  end
end
