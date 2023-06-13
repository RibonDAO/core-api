# == Schema Information
#
# Table name: crypto_users
#
#  id             :uuid             not null, primary key
#  wallet_address :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require 'rails_helper'

RSpec.describe CryptoUser, type: :model do
  describe 'Active record validation' do
    it { is_expected.to have_many(:person_payments) }
  end
end
