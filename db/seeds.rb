unless Rails.env.production?
  ribon_config = FactoryBot.create(:ribon_config)

  non_profit = FactoryBot.create(:non_profit, :with_impact)

  integration = FactoryBot.create(:integration)

  admin = FactoryBot.create(:admin)

  user = FactoryBot.create(:user)

  chain = FactoryBot.create(:chain)
end
