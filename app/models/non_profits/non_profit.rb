class NonProfit < ApplicationRecord
  extend Mobility

  STATUSES = %w[active inactive].freeze
  
  translates :impact_description, :description, type: :string

  has_one_attached :logo
  has_one_attached :main_image
  has_one_attached :background_image
  has_one_attached :cover_image
  has_many :non_profit_impacts

  validates :name, :impact_description, :wallet_address, :status, presence: true
  validates :status, inclusion: { in: STATUSES, message: '%<value>s is not a valid status' }

  def impact_for(date: Time.zone.now)
    non_profit_impacts.find_by('start_date <= ? AND end_date >= ?', date, date)
  end

  def impact_by_ticket(date: Time.zone.now)
    impact_for(date:)&.impact_by_ticket
  end
end
