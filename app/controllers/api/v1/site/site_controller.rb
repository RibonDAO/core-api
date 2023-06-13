module Api
  module V1
    module Site
      class SiteController < ApplicationController
        before_action :set_language

        include ActionView::Helpers::NumberHelper

        def non_profits
          @non_profits = NonProfit.where(status: :active).last(3)
          render json: SiteNonProfitsBlueprint.render(@non_profits)
        end

        def total_donations
          balance = BalanceHistory
                    .where('created_at > ?', Time.zone.yesterday)
                    .where('created_at < ?', Time.zone.today).sum(:balance)&.round
          if params[:language] == 'pt-BR'
            total_brl = convert_to_brl(balance)
            render json: { total_donations: "R$ #{number_with_delimiter(total_brl, delimiter: '.')}" }
          else
            render json: { total_donations: "#{number_with_delimiter(balance)} USDC" }
          end
        end

        def total_impacted_lives
          render json: { total_impacted_lives: '470.770' }
        end

        private

        def set_language
          I18n.locale = params[:language]&.to_sym || :en
        end

        def convert_to_brl(value)
          Currency::Converters.convert_to_brl(value:, from: 'USD').to_f.round
        end
      end
    end
  end
end
