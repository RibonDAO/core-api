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
class UserTasksStatistic < ApplicationRecord
  belongs_to :user

  def contributor
    user.promoter?
  end
end
