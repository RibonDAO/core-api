# == Schema Information
#
# Table name: person_payments
#
#  id                 :bigint           not null, primary key
#  amount_cents       :integer
#  currency           :integer
#  error_code         :string
#  liquid_value_cents :integer
#  paid_date          :datetime
#  payer_type         :string
#  payment_method     :integer
#  receiver_type      :string
#  refund_date        :datetime
#  status             :integer          default("processing")
#  usd_value_cents    :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  external_id        :string
#  integration_id     :bigint
#  offer_id           :bigint
#  payer_id           :uuid
#  person_id          :uuid
#  receiver_id        :bigint
#
require 'rails_helper'

RSpec.describe PersonPayment, type: :model do
  subject(:person_payment) { create(:person_payment, person_payment_fee:, amount_cents:, offer:) }

  let(:person_payment_fee) { build(:person_payment_fee, crypto_fee_cents: 100, card_fee_cents: 100) }
  let(:amount_cents) { nil }
  let(:offer) { build(:offer, price_cents: 1200, currency: :usd) }

  describe 'validations' do
    it { is_expected.to belong_to(:payer) }
    it { is_expected.to belong_to(:offer).optional }
    it { is_expected.to have_many(:person_blockchain_transactions) }
    it { is_expected.to have_one(:person_payment_fee) }
    it { is_expected.to validate_presence_of(:paid_date) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:payment_method) }
  end

  describe '.without_contribution' do
    let!(:person_payment_without_contribution) { create(:person_payment) }
    let(:person_payment_with_contribution) { create(:person_payment) }

    before do
      create(:contribution, person_payment: person_payment_with_contribution)
    end

    it 'returns only person_payments without contribution' do
      expect(described_class.without_contribution).to eq([person_payment_without_contribution])
    end
  end

  describe '#amount' do
    context 'when there is an amount_cents' do
      let(:amount_cents) { 1500 }

      it 'returns the amount_value' do
        expect(person_payment.amount).to eq 15.0
      end
    end

    context 'when there is not amount_cents' do
      let(:amount_cents) { nil }

      it 'returns the offer price_value' do
        expect(person_payment.amount).to eq 12.0
      end
    end
  end

  describe '#amount_value' do
    let(:amount_cents) { 2000 }

    it 'returns the amount_cents formatted' do
      expect(person_payment.amount_value).to eq 20.0
    end
  end

  describe '#set_fees' do
    subject(:person_payment) { create(:person_payment, amount_cents:, offer:) }

    let(:amount_cents) { 1500 }

    before do
      command = command_double(klass: Givings::Card::CalculateCardGiving,
                               result: { card_fee: OpenStruct.new({ cents: 67 }),
                                         crypto_fee: OpenStruct.new({ cents: 3 }) })
      allow(Givings::Card::CalculateCardGiving).to receive(:call).and_return(command)
    end

    it 'creates a person_payment_fee with correct params' do
      person_payment.set_fees
      fee = person_payment.reload.person_payment_fee

      expect(fee.card_fee_cents).to eq 67
      expect(fee.crypto_fee_cents).to eq 3
    end
  end

  describe '#crypto_amount' do
    let(:amount_cents) { 1500 }

    context 'when the currency is usd' do
      it 'returns the amount minus the fees' do
        amount = person_payment.amount
        fees = person_payment_fee.crypto_fee + person_payment_fee.card_fee

        expect(person_payment.crypto_amount).to eq amount - fees
      end
    end

    context 'when the currency is brl' do
      include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd' } }

      it 'returns the amount minus the fees converted to brl' do
        person_payment.update(currency: :brl)
        amount = person_payment.amount
        fees = person_payment_fee.crypto_fee + person_payment_fee.card_fee
        convert_factor_brl_usd = 0.1843 # comes from the conversion_rate_brl_usd request

        expect(person_payment.crypto_amount).to eq ((amount - fees) * convert_factor_brl_usd).round(2)
      end
    end
  end
end
