unless Rails.env.production?
  ribon_config = FactoryBot.create(:ribon_config) if RibonConfig.count.zero?
  
  cause = FactoryBot.create(:cause) if Cause.count.zero?
  
  non_profit = FactoryBot.create(:non_profit, cause:) if NonProfit.count.zero?

  integration = FactoryBot.create(:integration) if Integration.count.zero?

  batch = FactoryBot.create(:batch) if Batch.count.zero?
  
  donation = FactoryBot.create(:donation, non_profit:, integration:) if Donation.count.zero?

  chain = FactoryBot.create(:chain) if Chain.count.zero?

  token = FactoryBot.create(:token, chain:) if Token.count.zero?

  pool = FactoryBot.create(:pool, token:, cause:) if Pool.count.zero?
  
  article = FactoryBot.create(:article) if Article.count.zero?
  
  balance_history = FactoryBot.create(:balance_history, cause:, pool:) if BalanceHistory.count.zero?
  
  big_donor = FactoryBot.create(:big_donor) if BigDonor.count.zero?
  
  donation_batch = FactoryBot.create(:donation_batch, donation:, batch:) if DonationBatch.count.zero?
  
  integration_task = FactoryBot.create(:integration_task, integration:) if IntegrationTask.count.zero?
  
  integration_wallet = FactoryBot.create(:integration_wallet) if IntegrationWallet.count.zero?
  
  non_profit_impact = FactoryBot.create(:non_profit_impact, non_profit:) if NonProfitImpact.count.zero?

  non_profit_pool = FactoryBot.create(:non_profit_pool, non_profit:, pool:) if NonProfitPool.count.zero?

  non_profit_wallet = FactoryBot.create(:non_profit_wallet, owner: non_profit) if NonProfitWallet.count.zero?

  user = FactoryBot.create(:user) if User.count.zero?

  user_donation_stats = FactoryBot.create(:user_donation_stats, user:) if UserDonationStats.count.zero?

  voucher = FactoryBot.create(:voucher, integration:, donation:) if Voucher.count.zero?

  Rails.logger.debug 'Seed completed!' unless Rails.env.test?
end
