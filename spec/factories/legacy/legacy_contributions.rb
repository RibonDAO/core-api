# == Schema Information
#
# Table name: legacy_contributions
#
#  id                      :bigint           not null, primary key
#  day                     :datetime
#  from_subscription       :boolean
#  legacy_payment_method   :integer
#  legacy_payment_platform :integer
#  value                   :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  legacy_payment_id       :integer
#  user_id                 :bigint           not null
#
FactoryBot.define do
  factory :legacy_contribution do
    user { build(:user) }
    value { 1 }
    day { '2023-05-09 09:13:12' }
    legacy_payment_id { 1 }
    legacy_payment_platform { 1 }
    legacy_payment_method { 1 }
    from_subscription { false }
  end
end
