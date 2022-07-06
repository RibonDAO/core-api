FactoryBot.define do
  factory :customer do
    name { 'a customer' }
    unique_address { 'customer@customer.com' }
    tax_id { '12345678901' }
    customer_keys { { stripe: "cus_#{SecureRandom.uuid}" } }
    association :user, factory: :user
  end
end
