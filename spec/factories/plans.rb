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
FactoryBot.define do
  factory :plan do
    daily_tickets { 1 }
    monthly_tickets { 1 }
    status { 1 }
    offer { build(:offer) }
  end
end
