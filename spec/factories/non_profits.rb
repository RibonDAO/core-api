# == Schema Information
#
# Table name: non_profits
#
#  id                             :bigint           not null, primary key
#  background_image_description   :string
#  confirmation_image_description :string
#  impact_description             :text
#  logo_description               :string
#  main_image_description         :string
#  name                           :string
#  status                         :integer          default("inactive")
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  cause_id                       :bigint
#
FactoryBot.define do
  factory :non_profit do
    name { 'Evidence Action' }
    status { :active }
    wallet_address { '0x6E060041D62fDd76cF27c582f62983b864878E8F' }
    impact_description { '1 day of water' }
    cause { build(:cause) }

    trait(:with_impact) do
      after(:create) do |non_profit|
        non_profit.non_profit_impacts
                  .create(usd_cents_to_one_impact_unit: 10, donor_recipient: 'donor',
                          impact_description: '1 day of water', measurement_unit: 'quantity_without_decimals',
                          start_date: 1.year.ago, end_date: 1.year.from_now)
      end
    end
  end
end
