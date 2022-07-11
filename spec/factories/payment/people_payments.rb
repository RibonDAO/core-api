FactoryBot.define do
  factory :people_payment do
    paid_date { '2021-09-20 12:20:41' }
    payment_method { :credit_card }
    status { :paid }
    association :people, factory: :people
    offer { build(:offer) }
  end
end
