# == Schema Information
#
# Table name: user_donation_stats
#
#  id                 :bigint           not null, primary key
#  last_donated_cause :bigint
#  last_donation_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :bigint           not null
#
FactoryBot.define do
  factory :user_donation_stats do
    user { build(:user) }
    last_donation_at { '2022-03-09 13:26:30' }
  end
end
