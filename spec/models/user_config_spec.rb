# == Schema Information
#
# Table name: user_configs
#
#  id                      :bigint           not null, primary key
#  allowed_email_marketing :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint           not null
#
require 'rails_helper'

RSpec.describe UserConfig, type: :model do
  describe '.validations' do
    subject(:user_config) { build(:user_config) }

    it { is_expected.to belong_to(:user) }
  end
end
