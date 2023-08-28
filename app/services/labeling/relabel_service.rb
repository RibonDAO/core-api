module Labeling
  class RelabelService
    attr_reader :from

    def initialize(from:)
      @from = from
    end

    def relabel
      ordered_records.each do |record|
        case record.class.to_s
        when 'Donation'
          deal_with_donation(record)
        when 'Contribution'
          deal_with_contribution(record)
        end
      end
    end

    private

    def deal_with_donation(donation)
      ActiveRecord::Base.transaction do
        donation.donation_contribution&.delete
        Service::Contributions::TicketLabelingService.new(donation:).label_donation
      end
    end

    def deal_with_contribution(contribution)
      ActiveRecord::Base.transaction do
        contribution.contribution_fees&.delete_all
        Service::Contributions::FeesLabelingService.new(contribution:).spread_fee_to_payers
      end
    end

    def ordered_records
      @ordered_records ||= combined_records.sort_by do |record|
        [record.created_at || record.person_payment&.person_blockchain_transaction&.succeeded_at]
      end
    end

    def combined_records
      @combined_records ||= donations.to_a.concat(contributions.to_a)
    end

    def donations
      @donations ||= Donation.all.where('created_at >= ?', from)
    end

    def contributions
      @contributions ||= Contribution.where('contributions.created_at >= ?', from).with_payment_in_blockchain
    end
  end
end
