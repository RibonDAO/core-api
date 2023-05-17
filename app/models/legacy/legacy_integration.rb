# == Schema Information
#
# Table name: legacy_integrations
#
#  id             :bigint           not null, primary key
#  name           :string
#  total_donors   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  integration_id :bigint
#  legacy_id      :bigint
#
class LegacyIntegration < ApplicationRecord
  belongs_to :integration, optional: true

  validates :name, :legacy_id, presence: true

  has_many :legacy_integration_impacts
end
