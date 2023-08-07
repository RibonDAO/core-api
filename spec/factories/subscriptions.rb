# == Schema Information
#
# Table name: subscriptions
#
#  id             :bigint           not null, primary key
#  cancel_date    :datetime
#  payer_type     :string
#  payment_method :string
#  platform       :string
#  receiver_type  :string
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  external_id    :string
#  offer_id       :uuid
#  payer_id       :uuid
#  receiver_id    :uuid
#
FactoryBot.define do
  factory :subscription do
    cancel_date { nil }
    association :payer, factory: :customer
    status { nil }
    payment_method { nil }
    offer { build(:offer) }
    receiver { build(:non_profit) }
    external_id { nil }
  end
end