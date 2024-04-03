module Api
  module V1
    module Givings
      class OffersController < ApplicationController
        def index
          @offers_blueprint = Rails.cache.fetch('active_offers', expires_in: 30.minutes) do
            @offers = Offer.where(active: true, currency:, subscription:, category:)
                           .order('position_order ASC, price_cents ASC')
            OfferBlueprint.render(@offers, view: :plan)
          end
          render json: @offers_blueprint
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

        def category
          params[:category] || 'direct_contribution'
        end

        def offer_params
          params.permit(:id, :price_cents, :currency, :active, :subscription, :category,
                        offer_gateway_attributes: %i[id gateway external_id])
        end
      end
    end
  end
end
