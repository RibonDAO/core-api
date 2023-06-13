require 'rails_helper'

RSpec.describe Service::Users::Statistics, type: :service do
  subject(:service) { described_class.new(donations:, user:, customer:) }

  let(:user) { create(:user) }
  let(:customer) { create(:customer, user:, email: user.email) }
  let(:donations) { Donation.where(user:) }
  let(:non_profit) { create(:non_profit) }
  let(:non_profit2) { create(:non_profit) }
  let(:cause) { create(:cause) }

  before do
    create_list(:donation, 2, value: 10, user:, non_profit:)
    create_list(:donation, 2, value: 10, user:, non_profit: non_profit2)
    create_list(:person_payment, 2, status: :paid, payer: customer, receiver: cause,
                                    offer: create(:offer, currency: :usd, price_cents: 1000))

    allow(Currency::Converters).to receive(:convert_to_usd).and_return(1)

    allow(Currency::Converters).to receive(:convert_to_brl).and_return(1)
  end

  describe '#total_causes' do
    it 'returns the total causes count' do
      expect(service.total_causes).to eq [non_profit.cause_id, non_profit2.cause_id, cause.id]
    end
  end

  describe '#total_tickets' do
    it 'returns the total tickets count' do
      expect(service.total_tickets).to eq 4
    end
  end

  describe '#total_non_profits' do
    it 'returns the total non_profits count' do
      expect(service.total_non_profits).to eq [non_profit.id, non_profit2.id]
    end
  end

  describe '#total_donated' do
    it 'returns the total donated count' do
      expect(service.total_donated).to eq({ brl: 1.0, usd: 21.0 })
    end
  end
end
