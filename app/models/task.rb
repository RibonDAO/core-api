# == Schema Information
#
# Table name: tasks
#
#  id         :bigint           not null, primary key
#  actions    :text
#  rules      :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Task < ApplicationRecord
  has_many :user_completed_tasks
end
