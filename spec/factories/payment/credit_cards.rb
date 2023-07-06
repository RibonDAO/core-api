FactoryBot.define do
  factory :credit_card do
    initialize_with do
      new(
        cvv: '411',
        number: '4111111111111111',
        name: 'User Test',
        expiration_month: '08',
        expiration_year: '22'
      )
    end
    trait(:blocked) do
      initialize_with do
        new(
          cvv: '123',
          number: '4100000000000019',
          name: 'User Test',
          expiration_month: '12',
          expiration_year: '24'
        )
      end
    end
  end
end
