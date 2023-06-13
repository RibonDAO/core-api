# == Schema Information
#
# Table name: legacy_users
#
#  id         :bigint           not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  legacy_id  :integer
#  user_id    :bigint
#
FactoryBot.define do
  factory :legacy_user do
    email { 'legacy@user.com' }
    legacy_id { 1 }
    user { build(:user) }
  end
end
