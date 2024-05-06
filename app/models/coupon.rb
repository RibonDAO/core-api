# == Schema Information
#
# Table name: coupons
#
#  id                 :uuid             not null, primary key
#  available_quantity :integer
#  expiration_date    :datetime
#  number_of_tickets  :integer
#  status             :integer          default("inactive")
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Coupon < ApplicationRecord
  validates :number_of_tickets, presence: true

  has_many :user_coupons
  has_many :user_expired_coupons
  has_one :coupon_message

  accepts_nested_attributes_for :coupon_message

  enum status: {
    inactive: 0,
    active: 1
  }

  def expired?
    return false if expiration_date.blank?

    Time.zone.now >= expiration_date
  end

  def link
    "#{base_url}#{id}"
  end

  def reward_text
    coupon_message&.reward_text
  end

  private

  def base_url
    RibonCoreApi.config[:coupon_address][:base_url]
  end
end
