# == Schema Information
#
# Table name: subscriptions
#
#  id                       :bigint           not null, primary key
#  cancel_date              :datetime
#  payer_type               :string
#  payment_method           :string
#  platform                 :string
#  receiver_type            :string
#  status                   :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  external_subscription_id :string
#  offer_id                 :bigint
#  payer_id                 :uuid
#  receiver_id              :uuid
#
FactoryBot.define do
  factory :subscription do
    cancel_date { nil }
    association :payer, factory: :customer
    status { nil }
    payment_method { nil }
    offer { build(:offer) }
    receiver { build(:non_profit) }
    external_subscription_id { nil }
  end
end
