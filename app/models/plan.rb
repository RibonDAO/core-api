# == Schema Information
#
# Table name: plans
#
#  id              :bigint           not null, primary key
#  daily_tickets   :integer
#  monthly_tickets :integer
#  status          :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  offer_id        :bigint           not null
#
class Plan < ApplicationRecord
  belongs_to :offer

  validates :daily_tickets, :monthly_tickets, :status, presence: true

  enum status: {
    inactive: 0,
    active: 1
  }
end
