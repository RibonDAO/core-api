# == Schema Information
#
# Table name: causes
#
#  id                      :bigint           not null, primary key
#  cover_image_description :string
#  main_image_description  :string
#  name                    :string
#  status                  :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
require 'rails_helper'

RSpec.describe Cause, type: :model do
  describe '.validations' do
    subject { build(:cause) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to have_many(:person_payments) }
    it { is_expected.to have_many(:subscriptions) }
  end

  describe '.associations' do
    subject { build(:cause) }

    it { is_expected.to have_many(:non_profits) }
  end

  describe '#default_pool' do
    subject(:cause) { create(:cause) }

    let!(:chain) { create(:chain) }
    let!(:chain2) { create(:chain) }
    let!(:pool) { create(:pool, cause:, token: create(:token, chain:)) }
    let!(:pool2) { create(:pool, cause:, token: create(:token, chain: chain2)) }

    before do
      create(:ribon_config, default_chain_id: chain.chain_id)
    end

    it 'returns the pool of the default chain' do
      expect(cause.default_pool).to eq pool
    end

    it 'does not return other pools' do
      expect(cause.default_pool).not_to eq pool2
    end
  end

  describe '#status' do
    context 'when the cause has non_profits but its inactive' do
      let(:cause) { create(:cause, non_profits: [create(:non_profit, status: :active)], status: :inactive) }

      it 'returns false' do
        expect(cause.status).to eq 'inactive'
      end
    end

    context 'when the cause has active non_profits associated' do
      let(:cause) { create(:cause, non_profits: [create(:non_profit, status: :active)]) }

      it 'returns true' do
        expect(cause.status).to eq 'active'
      end
    end
  end
end
