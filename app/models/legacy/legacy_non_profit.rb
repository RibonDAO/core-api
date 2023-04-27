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
  has_many :legacy_user_impacts, dependent: :destroy

  has_one_attached :logo
  validates :name, :logo_url, :impact_cost_ribons, :impact_cost_usd, :impact_description, :legacy_id,
            presence: true
end
