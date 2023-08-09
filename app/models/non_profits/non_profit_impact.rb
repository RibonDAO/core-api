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
class NonProfitImpact < ApplicationRecord
  extend Mobility

  translates :impact_description, :donor_recipient, type: :string, locale_accessors: %i[en pt-BR]

  belongs_to :non_profit

  validates :usd_cents_to_one_impact_unit, :start_date, :donor_recipient, presence: true

  enum measurement_unit: {
    days_months_and_years: 'days_months_and_years',
    quantity_without_decimals: 'quantity_without_decimals'
  }

  def impact_by_ticket
    (RibonConfig.default_ticket_value / usd_cents_to_one_impact_unit).to_i
  rescue StandardError
    0
  end
end
