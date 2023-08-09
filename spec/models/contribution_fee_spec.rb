# == Schema Information
#
# Table name: contribution_fees
#
#  id                                        :bigint           not null, primary key
#  fee_cents                                 :integer
#  payer_contribution_increased_amount_cents :integer
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  contribution_id                           :bigint           not null
#  payer_contribution_id                     :bigint           not null
#
require 'rails_helper'

RSpec.describe ContributionFee, type: :model do
  describe '.validations' do
    subject { build(:contribution_fee) }

    it { is_expected.to validate_numericality_of(:fee_cents).is_greater_than_or_equal_to(0) }
  end
end
