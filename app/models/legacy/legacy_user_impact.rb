# == Schema Information
#
# Table name: legacy_user_impacts
#
#  id                   :bigint           not null, primary key
#  donations_count      :integer
#  total_donated_usd    :decimal(, )
#  total_impact         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  legacy_non_profit_id :bigint           not null
#  legacy_user_id       :bigint
#
class LegacyUserImpact < ApplicationRecord
  extend Mobility

  translates :total_impact, type: :string, locale_accessors: %i[en pt-BR]

  belongs_to :legacy_user
  belongs_to :legacy_non_profit, optional: true

  validates :donations_count, :total_impact, presence: true
end
