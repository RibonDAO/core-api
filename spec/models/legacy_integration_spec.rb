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
require 'rails_helper'

RSpec.describe LegacyIntegration, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
