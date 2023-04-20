# == Schema Information
#
# Table name: legacy_non_profits
#
#  id                 :bigint           not null, primary key
#  cost_of_one_impact :integer
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

  validates :name, :logo_url, :cost_of_one_impact, :impact_description, :legacy_id, presence: true
end
