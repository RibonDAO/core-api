# == Schema Information
#
# Table name: legacy_contributions
#
#  id                      :bigint           not null, primary key
#  day                     :datetime
#  from_subscription       :boolean
#  legacy_payment_method   :integer
#  legacy_payment_platform :integer
#  value_cents             :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  legacy_payment_id       :integer
#  legacy_user_id          :bigint
#
class LegacyContribution < ApplicationRecord
  belongs_to :legacy_user

  validates :day, :value_cents, :legacy_payment_id, :legacy_payment_method,
            :legacy_payment_platform, presence: true

  enum legacy_payment_method: {
    pix: 0,
    credit_card: 1
  }

  enum legacy_payment_platform: {
    stripe: 0,
    iugu: 1
  }

  def currency
    :brl
  end
end
