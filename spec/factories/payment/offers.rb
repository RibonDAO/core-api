FactoryBot.define do
  factory :offer do
    currency { 0 }
    subscription { 0 }
    price_cents { 1 }
    active { false }
    title { 'Super oferta de fim de ano' }
    position_order { 1 }
    offer_gateway { build(:offer_gateway) }

    trait :with_stripe_global do
      offer_gateway { build(:offer_gateway, gateway: 'stripe_global') }
    end

    trait :subscription do
      offer_gateway { build(:offer_gateway, external_id: 'price_1NVEIqJuOnwQq9QxBMaE2yul') }
    end
  end
end
