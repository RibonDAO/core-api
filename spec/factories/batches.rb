# == Schema Information
#
# Table name: batches
#
#  id         :bigint           not null, primary key
#  amount     :decimal(, )
#  cid        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :batch do
    cid { 'cid' }
    amount { 100 }

    trait(:with_integration_and_non_profit) do
      after(:create) do |batch|
        integration = create(:integration)
        non_profit = create(:non_profit)
        donation = create(:donation, integration:, non_profit:)
        create(:donation_batch, batch:, donation:)
      end
    end
  end
end
