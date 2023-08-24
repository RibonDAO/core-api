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
          Service::Contributions::TicketLabelingService.new(donation: record).label_donation
        when 'Contribution'
          Service::Contributions::FeesLabelingService.new(contribution: record).spread_fee_to_payers
        end
      end
    end

    private

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
