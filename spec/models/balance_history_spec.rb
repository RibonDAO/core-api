# == Schema Information
#
# Table name: balance_histories
#
#  id             :bigint           not null, primary key
#  amount_donated :decimal(, )
#  balance        :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  cause_id       :bigint           not null
#  pool_id        :bigint           not null
#
require 'rails_helper'

RSpec.describe BalanceHistory, type: :model do
  describe '.validations' do
    subject { build(:balance_history) }

    it { is_expected.to validate_presence_of(:balance) }
    it { is_expected.to validate_presence_of(:amount_donated) }
  end
end
