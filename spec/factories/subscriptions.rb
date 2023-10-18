# == Schema Information
#
# Table name: subscriptions
#
#  id                   :bigint           not null, primary key
#  cancel_date          :datetime
#  next_payment_attempt :datetime
#  payer_type           :string
#  payment_method       :string
#  platform             :string
#  receiver_type        :string
#  status               :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_id          :string
#  integration_id       :bigint
#  offer_id             :bigint
#  payer_id             :uuid
#  receiver_id          :bigint
#
FactoryBot.define do
  factory :subscription do
    cancel_date { nil }
    association :payer, factory: :customer
    status { :active }
    payment_method { 'credit_card' }
    offer { build(:offer) }
    receiver { build(:non_profit) }
    external_id { nil }
    association :integration
  end
end
