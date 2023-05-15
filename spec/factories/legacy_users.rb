# == Schema Information
#
# Table name: legacy_users
#
#  id         :bigint           not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
FactoryBot.define do
  factory :legacy_user do
    email { 'legacy@user.com' }
    user { build(:user) }
  end
end
