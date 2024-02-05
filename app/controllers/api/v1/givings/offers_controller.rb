module Api
  module V1
    module Givings
      class OffersController < ApplicationController
        def index
          @offers = Offer.where(active: true, currency:, subscription:)
                         .order('position_order ASC, price_cents ASC')

          render json: OfferBlueprint.render(@offers, view: :minimal)
        end

        def show
          @offer = Offer.find offer_params[:id]

          render json: OfferBlueprint.render(@offer)
        end

        private

        def currency
          params[:currency] || :brl
        end

        def subscription
          params[:subscription] || false
        end

        def offer_params
          params.permit(:id, :price_cents, :currency, :active, :subscription,
                        offer_gateway_attributes: %i[id gateway external_id])
        end
      end
    end
  end
end
