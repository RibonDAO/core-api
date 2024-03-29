FactoryBot.define do
  factory :order do
    initialize_with do
      Order.from(
        build(:person_payment),
        build(:credit_card),
        :purchase
      )
    end
  end
end
