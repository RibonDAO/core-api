module Labeling
  class RelabelService
    attr_reader :from

    def initialize(from:)
      @from = from
    end

    def relabel
      setup_records

      ordered_records.each do |record|
        case record['record_type']
        when 'Donation'
          donation = Donation.find(record['id'])
          deal_with_donation(donation)
        when 'PersonBlockchainTransaction'
          contribution = PersonBlockchainTransaction.find(record['id']).person_payment&.contribution
          deal_with_contribution(contribution) if contribution
        end
      end
    end

    def setup_records
      ActiveRecord::Base.transaction do
        @contributions = Contribution.where(
          "created_at >= ? and
          (
            (receiver_type = 'Cause' and receiver_id != 4) or
            (receiver_type = 'NonProfit' and receiver_id not in (3,4,5,6,8,9))
          )", 3.years.ago
        )
        ContributionBalance.where(contribution: @contributions).delete_all
        @contributions.each(&:set_contribution_balance)
        ContributionFee.where(contribution: @contributions).delete_all

        DonationContribution.where(donation: Donation.where(
          'created_at >= ? AND donations.non_profit_id not in (3,4,5,6,8,9)', from
        )).delete_all
      end
    end

    def ordered_records
      @ordered_records ||= begin
        combined_query = <<~SQL.squish
          #{donations.to_sql}
          UNION
          #{person_blockchain_transactions.to_sql}
        SQL

        ordered_query = <<~SQL.squish
          SELECT * FROM (#{combined_query}) AS combined_records
          ORDER BY order_date
        SQL

        ActiveRecord::Base.connection.execute(ordered_query)
      end
    end

    private

    def deal_with_donation(donation)
      Service::Contributions::TicketLabelingService.new(donation:).label_donation
    end

    def deal_with_contribution(contribution)
      Service::Contributions::FeesLabelingService.new(contribution:).spread_fee_to_payers
    end

    def donations
      @donations ||= Donation.select("donations.id, donations.created_at AS order_date, 'Donation' AS record_type")
                             .where('donations.created_at >= ? AND
                              donations.non_profit_id not in (3,4,5,6,8,9)', from)
    end

    def person_blockchain_transactions
      @person_blockchain_transactions ||=
        PersonBlockchainTransaction.joins(:person_payment).select("person_blockchain_transactions.id,
        COALESCE(person_blockchain_transactions.succeeded_at,
            person_blockchain_transactions.created_at) AS order_date,
      'PersonBlockchainTransaction' AS record_type")
                                   .where(
                                     "person_blockchain_transactions.succeeded_at >= ?
                                                                       AND
          (
            (person_payments.receiver_type = 'Cause' and person_payments.receiver_id != 4) OR
            (person_payments.receiver_type = 'NonProfit' and
              person_payments.receiver_id not in (3,4,5,6,8,9))
          )", from
                                   )
    end
  end
end
