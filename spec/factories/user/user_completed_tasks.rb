# == Schema Information
#
# Table name: user_completed_tasks
#
#  id                :uuid             not null, primary key
#  last_completed_at :datetime         not null
#  task_identifier   :string           not null
#  times_completed   :integer          default(0), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
FactoryBot.define do
  factory :user_completed_task do
    user { build(:user) }
    task_identifier { 'task_identifier' }
    last_completed_at { Time.zone.now }
    times_completed { 0 }
  end
end
