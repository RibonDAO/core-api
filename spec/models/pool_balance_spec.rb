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
require 'rails_helper'

RSpec.describe PoolBalance, type: :model do
  subject(:pool_balance) { create(:pool_balance) }

  describe 'validations' do
    it { is_expected.to belong_to(:pool) }
    it { is_expected.to validate_presence_of(:balance) }
  end
end
