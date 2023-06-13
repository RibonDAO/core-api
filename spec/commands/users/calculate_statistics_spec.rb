# frozen_string_literal: true

require 'rails_helper'

describe Users::CalculateStatistics do
  describe '.call' do
    subject(:command) do
      described_class.call(user:, wallet_address:, customer:, donations:)
    end

    context 'when has just user' do
      let(:wallet_address) { nil }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:, email: user.email) }
      let(:donations) { Donation.where(user:) }
      let(:non_profit) { create(:non_profit) }
      let(:non_profit2) { create(:non_profit) }

      before do
        create_list(:person_payment, 2, status: :paid, payer: customer, receiver_type: 'NonProfit',
                                        receiver_id: non_profit.id,
                                        offer: create(:offer, currency: :usd, price_cents: 1000))
        create_list(:person_payment, 2, status: :paid, payer: customer, receiver_type: 'Cause',
                                        receiver_id: non_profit2.cause_id,
                                        offer: create(:offer, currency: :brl, price_cents: 1000))
        allow(Currency::Converters).to receive(:convert_to_usd).and_return(1)

        allow(Currency::Converters).to receive(:convert_to_brl).and_return(1)
      end

      it 'returns the statistics' do
        command
        expect(command.result).to eq({ total_causes: 1, total_non_profits: 1, total_tickets: 0,
                                       total_donated: { usd: 21.0, brl: 21.0 } })
      end
    end

    context 'when has user and wallet' do
      let(:wallet_address) { '0x44d5e936dad202ec600b6a6a5' }
      let(:crypto_user) { create(:crypto_user) }
      let(:user) { create(:user) }
      let(:customer) { create(:customer, user:, email: user.email) }
      let(:donations) { Donation.where(user:) }
      let(:non_profit) { create(:non_profit) }
      let(:non_profit2) { create(:non_profit) }

      before do
        create_list(:person_payment, 2, status: :paid, payer: crypto_user,
                                        receiver_type: 'NonProfit', receiver_id: non_profit.id,
                                        offer: create(:offer, currency: :usd, price_cents: 1000))
        create_list(:person_payment, 2, status: :paid, payer: crypto_user, receiver_type: 'Cause',
                                        receiver_id: non_profit2.cause_id,
                                        offer: create(:offer, currency: :brl, price_cents: 1000))
        allow(Currency::Converters).to receive(:convert_to_usd).and_return(1)

        allow(Currency::Converters).to receive(:convert_to_brl).and_return(1)
      end

      it 'returns the statistics' do
        command
        expect(command.result).to eq({ total_causes: 1, total_non_profits: 1, total_tickets: 0,
                                       total_donated: { usd: 22.0, brl: 22.0 } })
      end
    end

    context 'when has just wallet' do
      let(:wallet_address) { '0x44d5e936dad202ec600b6a6a5' }
      let(:crypto_user) { create(:crypto_user) }
      let(:user) { nil }
      let(:customer) { nil }
      let(:donations) { nil }
      let(:non_profit) { create(:non_profit) }
      let(:non_profit2) { create(:non_profit) }

      before do
        create_list(:person_payment, 2, status: :paid, payer: crypto_user,
                                        receiver_type: 'NonProfit', receiver_id: non_profit.id,
                                        offer: create(:offer, currency: :usd, price_cents: 1000))
        create_list(:person_payment, 2, status: :paid, payer: crypto_user, receiver_type: 'Cause',
                                        receiver_id: non_profit2.cause_id,
                                        offer: create(:offer, currency: :brl, price_cents: 1000))
        allow(Currency::Converters).to receive(:convert_to_usd).and_return(1)

        allow(Currency::Converters).to receive(:convert_to_brl).and_return(1)
      end

      it 'returns the statistics' do
        command
        expect(command.result).to eq({ total_causes: 1, total_non_profits: 1, total_tickets: 0,
                                       total_donated: { usd: 21.0, brl: 21.0 } })
      end
    end
  end
end
