# == Schema Information
#
# Table name: donation_contributions
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  contribution_id :bigint           not null
#
FactoryBot.define do
  factory :donation_contribution do
    contribution { build(:contribution) }
  end
end
