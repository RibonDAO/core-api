require 'rails_helper'

RSpec.describe Service::CryptoUsers::Statistics, type: :service do
  subject(:service) { described_class.new(wallet_address:) }

  let(:wallet_address) { '0x44d5e936dad202ec600b6a6a5' }
  let(:crypto_user) { create(:crypto_user) }

  let(:non_profit) { create(:non_profit) }
  let(:non_profit2) { create(:non_profit) }

  before do
    create_list(:person_payment, 2, status: :paid, payer: crypto_user, receiver_type: 'NonProfit',
                                    receiver_id: non_profit.id,
                                    offer: create(:offer, currency: :usd, price_cents: 1000))
    create_list(:person_payment, 2, status: :paid, payer: crypto_user, receiver_type: 'Cause',
                                    receiver_id: non_profit2.cause_id,
                                    offer: create(:offer, currency: :usd, price_cents: 1000))

    allow(Currency::Converters).to receive(:convert_to_usd).and_return(1)

    allow(Currency::Converters).to receive(:convert_to_brl).and_return(1)
  end

  describe '#total_causes' do
    it 'returns the total causes count' do
      expect(service.total_causes).to eq [non_profit2.cause_id]
    end
  end

  describe '#total_non_profits' do
    it 'returns the total non_profits count' do
      expect(service.total_non_profits).to eq [non_profit.id]
    end
  end

  describe '#total_donated' do
    it 'returns the total donated count' do
      expect(service.total_donated).to eq({ brl: 1.0, usd: 41.0 })
    end
  end
end
