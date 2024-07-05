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
FactoryBot.define do
  factory :coupon do
    available_quantity { 1 }
    expiration_date { 2.months.from_now }
    number_of_tickets { 1 }
  end
end
