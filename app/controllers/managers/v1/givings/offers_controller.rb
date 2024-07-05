module Managers
  module V1
    module Givings
      class OffersController < ManagersController
        def index
          @offers = Offer.order('position_order ASC, price_cents ASC')

          render json: OfferBlueprint.render(@offers)
        end

        def show
          @offer = Offer.find offer_params[:id]

          render json: OfferBlueprint.render(@offer, view: :manager)
        end

        def create
          command = ::Offers::UpsertOffer.call(offer_params)
          if command.success?
            render json: OfferBlueprint.render(command.result, view: :manager), status: :created
          else
            render_errors(command.errors)
          end
        end

        def update
          command = ::Offers::UpsertOffer.call(offer_params)
          if command.success?
            render json: OfferBlueprint.render(command.result, view: :manager), status: :created
          else
            render_errors(command.errors)
          end
        end

        private

        def currency
          params[:currency] || :brl
        end

        def subscription
          params[:subscription] || false
        end

        def offer_params
          params.permit(:id, :price_cents, :currency, :active, :subscription, :category,
                        offer_gateway_attributes: %i[id gateway external_id],
                        plans_attributes: %i[id daily_tickets monthly_tickets status])
        end
      end
    end
  end
end
