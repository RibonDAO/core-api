# == Schema Information
#
# Table name: accounts
#
#  id                   :bigint           not null, primary key
#  confirmation_sent_at :datetime
#  confirmation_token   :string
#  confirmed_at         :datetime
#  image                :string
#  name                 :string
#  nickname             :string
#  provider             :string
#  remember_created_at  :datetime
#  tokens               :json
#  uid                  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint           not null
#
# spec/models/account_spec.rb
require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
  end

  describe '.validations' do
    subject { build(:account) }

    it { is_expected.to validate_presence_of(:uid) }
  end
end
