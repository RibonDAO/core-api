# == Schema Information
#
# Table name: non_profits
#
#  id                             :bigint           not null, primary key
#  background_image_description   :string
#  confirmation_image_description :string
#  impact_description             :text
#  logo_description               :string
#  main_image_description         :string
#  name                           :string
#  status                         :integer          default("inactive")
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  cause_id                       :bigint
#
require 'rails_helper'

RSpec.describe NonProfit, type: :model do
  describe '.validations' do
    subject { build(:non_profit) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:wallet_address) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to have_many(:non_profit_pools) }
    it { is_expected.to have_many(:pools).through(:non_profit_pools) }
    it { is_expected.to belong_to(:cause) }
  end

  describe '#impact_for' do
    subject(:non_profit) { build(:non_profit) }

    let(:date) { Date.parse('2022-02-02') }
    let(:non_profit_impact1) do
      create(:non_profit_impact, non_profit:, start_date: '2022-02-01', end_date: '2022-03-01')
    end
    let(:non_profit_impact2) do
      create(:non_profit_impact, non_profit:, start_date: '2021-06-01', end_date: '2021-09-01')
    end

    before do
      non_profit_impact1
      non_profit_impact2
    end

    it 'returns the non_profit_impact that includes the passed date' do
      expect(non_profit.impact_for(date:)).to eq non_profit_impact1
    end
  end

  describe '#impact_by_ticket' do
    subject(:non_profit) { build(:non_profit) }

    let(:date) { Date.parse('2022-02-02') }
    let(:non_profit_impact) do
      create(:non_profit_impact, non_profit:,
                                 start_date: '2022-02-01', end_date: '2022-03-01',
                                 usd_cents_to_one_impact_unit: 10)
    end

    before do
      create(:ribon_config, default_ticket_value: 100)
      non_profit_impact
    end

    it 'returns the impact by ticket' do
      expect(non_profit.impact_by_ticket(date:)).to eq 10
    end
  end

  describe 'if an non profit is created' do
    let(:non_profit) do
      create(:non_profit)
    end

    before do
      non_profit
    end

    it 'creates a new wallet' do
      expect(NonProfitWallet.count).to eq 1
      expect(non_profit.non_profit_wallets.reload.count).to eq 1
    end
  end

  describe 'if the wallet address is updated' do
    let(:non_profit) do
      create(:non_profit)
    end

    before do
      non_profit
      non_profit.update(wallet_address: 'newWalletAddress')
    end

    it 'creates a new wallet' do
      expect(NonProfitWallet.count).to eq 2
      expect(non_profit.non_profit_wallets.count).to eq 2
    end

    it 'returns the right address' do
      expect(non_profit.wallet_address).to eq 'newWalletAddress'
    end

    it 'has only one wallet active' do
      expect(non_profit.non_profit_wallets.reload.where(status: :active).count).to eq 1
    end
  end

  describe 'if the wallet address is updated with an old address' do
    let(:non_profit) do
      create(:non_profit, wallet_address: 'newWalletAddress')
    end

    before do
      non_profit
      non_profit.update(wallet_address: 'newWalletAddressActive')
      non_profit.update(wallet_address: 'newWalletAddress')
    end

    it 'does not create a new wallet' do
      expect(NonProfitWallet.count).to eq 2
    end

    it 'returns the right address' do
      expect(non_profit.wallet_address).to eq 'newWalletAddress'
    end

    it 'updates the status from the old wallet' do
      expect(non_profit.non_profit_wallets.reload.where(public_key: 'newWalletAddress').last.status).to eq 'active'
    end
  end

  describe 'if the wallet address was going to be updated with an old address, but the non profit was not saved' do
    let(:non_profit) do
      create(:non_profit, wallet_address: 'newWalletAddress')
    end

    before do
      non_profit
      non_profit.update(wallet_address: 'newWalletAddressActive')
      non_profit.wallet_address = 'newWalletAddress'
    end

    it 'returns the right address' do
      expect(non_profit.wallet_address).to eq 'newWalletAddressActive'
    end
  end
end
