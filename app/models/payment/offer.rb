# == Schema Information
#
# Table name: offers
#
#  id             :bigint           not null, primary key
#  active         :boolean
#  category       :integer          default("direct_contribution")
#  currency       :integer
#  position_order :integer
#  price_cents    :integer
#  subscription   :boolean
#  title          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Offer < ApplicationRecord
  has_one :offer_gateway, dependent: :nullify, inverse_of: :offer
  has_many :plans
  accepts_nested_attributes_for :offer_gateway, allow_destroy: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true

  delegate :gateway, to: :offer_gateway
  delegate :external_id, to: :offer_gateway

  accepts_nested_attributes_for :plans

  after_save :invalidate_cache

  enum currency: {
    brl: 0,
    usd: 1
  }

  enum category: {
    direct_contribution: 0,
    club: 1
  }

  def price_value
    price_cents / 100.0
  end

  def plan
    plans.where(status: :active).last
  end

  def invalidate_cache
    Rails.cache.delete_matched('active_offers_*')
  end
end
