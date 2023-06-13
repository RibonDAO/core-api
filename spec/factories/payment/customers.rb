FactoryBot.define do
  factory :customer do
    name { 'a customer' }
    sequence :email, 100 do |n|
      "customer#{n}@customer.com"
    end
    tax_id { '12345678901' }
    customer_keys { { stripe: "cus_#{SecureRandom.uuid}" } }
    association :user, factory: :user
  end
end
