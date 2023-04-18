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
  pending "add some examples to (or delete) #{__FILE__}"
end
