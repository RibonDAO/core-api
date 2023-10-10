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
FactoryBot.define do
  factory :user_config do
    allowed_email_marketing { false }
    user { build(:user) }
  end
end
