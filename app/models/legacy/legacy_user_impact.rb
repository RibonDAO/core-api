# == Schema Information
#
# Table name: legacy_user_impacts
#
#  id                   :bigint           not null, primary key
#  donations_count      :integer
#  total_donated_usd    :integer
#  total_impact         :string
#  user_created_at      :datetime
#  user_email           :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  legacy_non_profit_id :bigint           not null
#  user_id              :bigint
#  user_legacy_id       :integer
#
class LegacyUserImpact < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :legacy_non_profit, optional: true

  validates :user_email, :user_legacy_id, :user_created_at, :donations_count, :total_impact, presence: true
end
