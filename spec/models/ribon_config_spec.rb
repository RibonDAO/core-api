# == Schema Information
#
# Table name: ribon_configs
#
#  id                                        :bigint           not null, primary key
#  contribution_fee_percentage               :decimal(, )
#  default_ticket_value                      :decimal(, )
#  minimum_contribution_chargeable_fee_cents :integer
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
  end

  it 'acts like a singleton' do
    create(:ribon_config)

    expect { create(:ribon_config) }.to raise_error(StandardError)
  end
end
