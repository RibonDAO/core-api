# == Schema Information
#
# Table name: tickets
#
#  id             :bigint           not null, primary key
#  category       :integer          default("daily")
#  platform       :string
#  source         :integer          default("integration")
#  status         :integer          default("collected")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  external_id    :string
#  integration_id :bigint
#  user_id        :bigint           not null
#
class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :integration, optional: true

  validates :external_id, uniqueness: { scope: :integration_id }, allow_blank: true

  has_one :utm, as: :trackable

  enum status: {
    collected: 0,
    to_collect: 1
  }

  enum category: {
    daily: 0,
    monthly: 1,
    extra: 2
  }

  enum source: {
    integration: 0,
    club: 1,
    coupon: 2,
    business: 3
  }

  scope :receive_daily_tickets_from_club_today, lambda {
    where(created_at: Time.zone.now.all_day, source: :club, category: :daily)
  }

  scope :collected, lambda {
    where(status: :collected)
  }
end
