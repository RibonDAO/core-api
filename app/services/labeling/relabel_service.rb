module Labeling
  class RelabelService
    attr_reader :from

    def initialize(from:)
      @from = from
    end

    def relabel
      setup_records

      ordered_records.each do |record|
        case record.class.to_s
        when 'Donation'
          deal_with_donation(record)
        when 'Contribution'
          deal_with_contribution(record)
        end
      end
    end

    def setup_records
      ActiveRecord::Base.transaction do
        ContributionBalance.delete_all
        Contributions.all.each(&:set_contribution_balance)
        ContributionFee.delete_all
        DonationContribution.delete_all
      end
    end

    def ordered_records
      @ordered_records ||= combined_records.sort_by do |record|
        if record.class.to_s == 'Donation'
          record.created_at
        else
          record.person_payment&.person_blockchain_transaction&.succeeded_at || record.created_at
        end
      end
    end

    private

    def deal_with_donation(donation)
      donation_contribution = donation.donation_contribution

      ActiveRecord::Base.transaction do
        if donation_contribution
          Service::Contributions::DonationContributionDeleteService.new(donation_contribution:).delete
        end
        Service::Contributions::TicketLabelingService.new(donation:).label_donation
      end
    end

    def deal_with_contribution(contribution)
      ActiveRecord::Base.transaction do
        contribution.contribution_fees.each do |contribution_fee|
          Service::Contributions::ContributionFeeDeleteService.new(contribution_fee:).handle_fee_delete
        end
        Service::Contributions::FeesLabelingService.new(contribution:).spread_fee_to_payers
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
