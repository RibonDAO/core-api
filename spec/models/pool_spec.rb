# == Schema Information
#
# Table name: pools
#
#  id         :bigint           not null, primary key
#  address    :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  cause_id   :bigint
#  token_id   :bigint           not null
#
require 'rails_helper'

RSpec.describe Pool, type: :model do
  describe '.validations' do
    subject { build(:pool) }

    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to belong_to(:token) }
    it { is_expected.to have_many(:non_profit_pools) }
    it { is_expected.to have_one(:pool_balance) }
    it { is_expected.to have_many(:non_profits).through(:non_profit_pools) }
  end

  describe '#chain' do
    subject(:pool) { build(:pool) }

    it 'returns the chain of the token' do
      expect(pool.chain).to eq(pool.token.chain)
    end
  end
end
