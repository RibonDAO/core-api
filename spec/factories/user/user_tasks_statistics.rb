# == Schema Information
#
# Table name: user_tasks_statistics
#
#  id                           :bigint           not null, primary key
#  first_completed_all_tasks_at :datetime
#  streak                       :integer          default(0)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  user_id                      :bigint           not null
#
FactoryBot.define do
  factory :user_tasks_statistic do
    user { build(:user) }
    first_completed_all_tasks_at { Time.zone.now }
    streak { 1 }
  end
end
