# frozen_string_literal: true

module Service
  module Contributions
    class ContributionFeeDeleteService
      attr_reader :contribution_fee

      def initialize(contribution_fee:)
        @contribution_fee = contribution_fee
      end

      def handle_fee_delete
        ActiveRecord::Base.transaction do
          delete_contribution_fee
          update_contribution_balance
        end
      rescue StandardError => e
        Reporter.log(error: e)
      end

      private

      def update_contribution_balance
        ::Contributions::IncreaseContributionBalanceFee.call(contribution_balance:, fee_cents:)
      end

      def delete_contribution_fee
        @contribution_fee = contribution_fee.destroy
      end

      def contribution_balance
        contribution_fee.payer_contribution.contribution_balance
      end

      def fee_cents
        contribution_fee.fee_cents
      end
    end
  end
end
