# == Schema Information
#
# Table name: non_profit_impacts
#
#  id                           :bigint           not null, primary key
#  donor_recipient              :string
#  end_date                     :date
#  impact_description           :text
#  measurement_unit             :string
#  start_date                   :date
#  usd_cents_to_one_impact_unit :decimal(, )
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  non_profit_id                :bigint           not null
#
FactoryBot.define do
  factory :non_profit_impact do
    non_profit { nil }
    start_date { 1.year.ago }
    end_date { 1.year.from_now }
    usd_cents_to_one_impact_unit { 10 }
    impact_description { 'days of water' }
    donor_recipient { 'donor' }
    measurement_unit { 'days_months_and_years' }
  end
end
