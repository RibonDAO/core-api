FactoryBot.define do
  factory :guest do
    wallet_address { '0x44d5e936dad202ec600b6a6a5' }
    association :people, factory: :people
  end
end
