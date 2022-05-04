class NonProfit < ApplicationRecord
  extend Mobility
  translates :impact_description, :description, type: :string

  has_one_attached :logo
  has_one_attached :main_image
  has_one_attached :background_image
  has_one_attached :cover_image
  has_many :non_profit_impacts

  validates :name, :impact_description, :wallet_address, presence: true

  def impact_for(date: Time.zone.now)
    non_profit_impacts.find_by('start_date <= ? AND end_date >= ?', date, date)
  end

  def impact_by_ticket(date: Time.zone.now)
    RibonConfig.default_ticket_value / impact_for(date: date).usd_cents_to_one_impact_unit
  rescue StandardError
    0
  end
end
