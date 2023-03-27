FactoryBot.define do
  factory :person_payment do
    paid_date { '2021-09-20 12:20:41' }
    refund_date { nil }
    payment_method { :credit_card }
    amount_cents { 1000 }
    status { :processing }
    association :integration, factory: :integration
    association :payer, factory: :customer
    offer { build(:offer) }
    external_id { nil }
    receiver { build(:non_profit) }
    liquid_value_cents { 2000 }
  end
end
