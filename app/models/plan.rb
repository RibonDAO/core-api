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
  after_save :invalidate_cache
  enum status: {
    inactive: 0,
    active: 1
  }

  def invalidate_cache
    Rails.cache.delete('active_non_profits')
  end
end
