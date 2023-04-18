# == Schema Information
#
# Table name: pool_balances
#
#  id         :bigint           not null, primary key
#  balance    :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  pool_id    :bigint           not null
#
FactoryBot.define do
  factory :pool_balance do
    pool { build(:pool) }
    balance { '9.99' }
  end
end
