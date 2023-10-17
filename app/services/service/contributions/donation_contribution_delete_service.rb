# frozen_string_literal: true

module Service
  module Contributions
    class DonationContributionDeleteService
      attr_reader :donation_contribution

      def initialize(donation_contribution:)
        @donation_contribution = donation_contribution
      end

      def delete
        ActiveRecord::Base.transaction do
          delete_donation_contribution
          update_contribution_balance
        end
      rescue StandardError => e
        Reporter.log(error: e)
      end

      private

      def update_contribution_balance
        contribution_balance.tickets_balance_cents += value_cents
        contribution_balance.save
      end

      def delete_donation_contribution
        @donation_contribution = donation_contribution.destroy
      end

      def contribution_balance
        donation_contribution.contribution.contribution_balance
      end

      def value_cents
        donation_contribution.donation.value
      end
    end
  end
end
