# == Schema Information
#
# Table name: coupons
#
#  id                 :uuid             not null, primary key
#  available_quantity :integer
#  expiration_date    :datetime
#  number_of_tickets  :integer
#  reward_text        :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
class Coupon < ApplicationRecord
  extend Mobility

  translates :reward_text,  type: :string

  validates :number_of_tickets, :reward_text, :expiration_date, presence: true

  has_many :user_coupons
  has_many :user_expired_coupons
end
