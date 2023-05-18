# == Schema Information
#
# Table name: legacy_non_profits
#
#  id                 :bigint           not null, primary key
#  impact_cost_ribons :integer
#  impact_cost_usd    :decimal(, )
#  impact_description :string
#  logo_url           :string
#  name               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  current_id         :integer
#  legacy_id          :integer
#
class LegacyNonProfit < ApplicationRecord
  extend Mobility

  translates :impact_description, type: :string, locale_accessors: %i[en pt-BR]

  has_many :legacy_user_impacts, dependent: :destroy

  has_one_attached :logo
  validates :name, :impact_cost_ribons, :impact_cost_usd, :legacy_id,
            presence: true
end
