# == Schema Information
#
# Table name: donation_contributions
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  contribution_id :bigint           not null
#  donation_id     :bigint           not null
#
class DonationContribution < ApplicationRecord
  belongs_to :contribution
  belongs_to :donation

  delegate :value, to: :donation

  def self.last_contribution_payer_type
    last.contribution&.person_payment&.payer_type
  end
end
