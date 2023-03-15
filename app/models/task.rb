# == Schema Information
#
# Table name: tasks
#
#  id         :bigint           not null, primary key
#  actions    :text
#  title      :string
#  type       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Task < ApplicationRecord
  has_many :user_completed_tasks
end
