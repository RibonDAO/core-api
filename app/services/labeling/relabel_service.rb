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
        ContributionBalance.where('created_at >= ?', from).delete_all
        Contribution.where('created_at >= ?', from).each(&:set_contribution_balance)
        ContributionFee.where('created_at >= ?', from).delete_all
        DonationContribution.where('created_at >= ?', from).delete_all
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
                             .where('donations.created_at >= ?', from).joins(:non_profit)
                             .where(non_profits: { cause_id: 5 })
    end

    def person_blockchain_transactions
      @person_blockchain_transactions ||= PersonBlockchainTransaction
                                          .select("person_blockchain_transactions.id,
       COALESCE(person_blockchain_transactions.succeeded_at,
           person_blockchain_transactions.created_at) AS order_date,
    'PersonBlockchainTransaction' AS record_type")
                                          .where('person_blockchain_transactions.succeeded_at >= ?', from)
                                          .joins(:person_payment)
                                          .where(person_payments: { receiver_type: 'Cause' })
    end
  end
end
