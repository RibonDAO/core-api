# frozen_string_literal: true

module Users
  class CalculateStatistics < ApplicationCommand
    prepend SimpleCommand

    attr_reader :user, :wallet_address, :customer, :donations

    def initialize(user:, wallet_address:, customer:, donations:)
      @user = user
      @wallet_address = wallet_address
      @customer = customer
      @donations = donations
    end

    def call
      with_exception_handle do
        if user && wallet_address
          return { total_non_profits: total_crypto_user_non_profits,
                   total_donated: total_crypto_user_user_donate,
                   total_causes: total_crypto_user_user_causes,
                   total_tickets: donations.count }

        elsif wallet_address && !user

          return crypto_user_statistics_service.statistics

        else
          return user_statistics_service.statistics
        end
      end
    end

    private

    def user_statistics_service
      @user_statistics_service ||= Service::Users::Statistics.new(donations:, user:, customer:)
    end

    def crypto_user_statistics_service
      @crypto_user_statistics_service ||= Service::CryptoUsers::Statistics.new(wallet_address:)
    end

    def total_crypto_user_user_donate
      { brl: crypto_user_statistics_service.total_donated[:brl] + user_statistics_service.total_donated[:brl],
        usd: crypto_user_statistics_service.total_donated[:usd] + user_statistics_service.total_donated[:usd] }
    end

    def total_crypto_user_user_causes
      crypto_user_total_causes = crypto_user_statistics_service.total_causes || []
      user_total_causes = user_statistics_service.total_causes || []
      (crypto_user_total_causes + user_total_causes).uniq.count
    end

    def total_crypto_user_non_profits
      crypto_user_total_non_profits = crypto_user_statistics_service.total_non_profits || []
      user_total_non_profits = user_statistics_service.total_non_profits || []
      (crypto_user_total_non_profits + user_total_non_profits).uniq.count
    end
  end
end
