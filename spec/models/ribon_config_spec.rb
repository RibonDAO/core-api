# == Schema Information
#
# Table name: ribon_configs
#
#  id                                        :bigint           not null, primary key
#  contribution_fee_percentage               :decimal(, )
#  default_ticket_value                      :decimal(, )
#  disable_labeling                          :boolean          default(FALSE)
#  minimum_contribution_chargeable_fee_cents :integer
#  minimum_version_required                  :string           default("0.0.0")
#  ribon_club_fee_percentage                 :decimal(, )
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  default_chain_id                          :integer
#
require 'rails_helper'

RSpec.describe RibonConfig, type: :model do
  describe 'validations' do
    subject { build(:ribon_config) }

    it { is_expected.to validate_presence_of(:default_ticket_value) }
    it { is_expected.to validate_presence_of(:default_chain_id) }
    it { is_expected.to validate_presence_of(:contribution_fee_percentage) }
    it { is_expected.to validate_presence_of(:ribon_club_fee_percentage) }
  end

  it 'acts like a singleton' do
    create(:ribon_config)

    expect { create(:ribon_config) }.to raise_error(StandardError)
  end
end
