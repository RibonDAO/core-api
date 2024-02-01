module Labeling
  class RelabelService
    attr_reader :from

    def initialize(from: 3.years.ago)
      @from = from < first_donation_or_contribution_date ? first_donation_or_contribution_date : from
    end

    def relabel
      setup_records
      label_unlabelled_records
    end

    def setup_records
      ActiveRecord::Base.transaction do
        @contributions = Contribution.where('created_at >= ?', from)
        ContributionBalance.where(contribution: @contributions).delete_all
        @contributions.each(&:set_contribution_balance)
        ContributionFee.where(contribution: @contributions).delete_all

        DonationContribution.where(donation: Donation.where('created_at >= ?', from)).delete_all
      end
    end

    def last_donation_or_contribution_date
      return if Donation.last.nil? && Contribution.last.nil?
      return Donation.last.created_at if Contribution.last.nil?
      return Contribution.last.created_at if Donation.last.nil?

      [Donation.last&.created_at, Contribution.last&.created_at].max
    end
    
    def first_donation_or_contribution_date
      return if Donation.first.nil? && Contribution.first.nil?
      return Donation.first.created_at if Contribution.first.nil?
      return Contribution.first.created_at if Donation.first.nil?

      [Donation.first&.created_at, Contribution.first&.created_at].min
    end

    # rubocop:disble Metrics/AbcSize
    def next_unlabelled_date
      return first_donation_or_contribution_date if DonationContribution.last.nil? && ContributionFee.last.nil?
      return DonationContribution.last&.donation&.created_at if ContributionFee.last.nil?
      return ContributionFee.last&.contribution&.created_at if DonationContribution.last.nil?

      [DonationContribution.last&.donation&.next&.created_at,
       ContributionFee.last&.contribution&.next&.created_at].max
    end

    def label_unlabelled_records
      from = next_unlabelled_date
      label_next_days
    end

    def label_next_days
      last_labelled_date = 0
      loop do
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

        @from = next_unlabelled_date
        break unless next_unlabelled_date.nil?
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
      byebug
      @donations ||= Donation.select("donations.id, donations.created_at AS order_date, 'Donation' AS record_type")
                            .left_outer_joins(:donation_contribution)
                             .where('donations.created_at >= ? AND donations.created_at < ? AND donation_contributions.id is NULL', from, from.next_day(5))
    end

    def person_blockchain_transactions
      @person_blockchain_transactions ||= PersonBlockchainTransaction
                                          .select("person_blockchain_transactions.id,
       COALESCE(person_blockchain_transactions.succeeded_at,
           person_blockchain_transactions.created_at) AS order_date,
    'PersonBlockchainTransaction' AS record_type")
                                          .where('person_blockchain_transactions.succeeded_at >= ? AND person_blockchain_transactions.succeeded_at <= ?', from, from.next_day(5))
    end
  end
end
