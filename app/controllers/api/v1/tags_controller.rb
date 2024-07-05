module Api
  module V1
    class TagsController < ApplicationController
      def index
        @tags_blueprints = Rails.cache.fetch("active_tags_#{I18n.locale}", expires_in: 30.minutes) do
          @tags = if current_user&.email&.include?('@ribon.io')
                    active_and_test_tags
                  else
                    active_tags
                  end
          TagBlueprint.render(@tags)
        end
        render json: @tags_blueprints
      end

      private

      def active_tags
        default_chain_id = Chain.default&.id

        Tag.where(status: :active)
           .where(id: Tag.select(:id)
                         .joins(non_profits: { cause: { pools: :pool_balance } })
                         .where(non_profits: { status: :active })
                         .where(causes: { status: :active })
                         .where(pools: { id: Pool.joins(:token)
                         .where(tokens: { chain_id: default_chain_id }).select(:id) })
                         .where('pool_balances.balance > 0'))
           .shuffle
      end

      def active_and_test_tags
        default_chain_id = Chain.default&.id

        Tag.where(status: %i[active test])
           .where(id: Tag.select(:id)
                         .joins(non_profits: { cause: { pools: :pool_balance } })
                         .where(non_profits: { status: %i[active test] })
                         .where(causes: { status: :active })
                         .where(pools: { id: Pool.joins(:token)
                         .where(tokens: { chain_id: default_chain_id }).select(:id) })
                         .where('pool_balances.balance > 0'))
           .shuffle
      end

      def tag_params
        params.permit(
          :id,
          :name,
          :status,
          non_profit_tags: %i[id non_profit_id tag_id]
        )
      end
    end
  end
end
