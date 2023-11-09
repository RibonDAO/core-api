# == Schema Information
#
# Table name: tasks
#
#  id                  :uuid             not null, primary key
#  actions             :string           not null
#  client              :string           default("web")
#  kind                :string           default("daily")
#  navigation_callback :string
#  title               :string           not null
#  visibility          :string           default("visible")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
class Task < ApplicationRecord
  validates :title, presence: true
  validates :actions, presence: true
end
