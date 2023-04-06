require 'rails_helper'

RSpec.describe DonationQueries, type: :model do
  describe '#amoun_free_donations' do
    let!(:cause) { create(:cause) }
    let!(:non_profit) { create(:non_profit, cause:) }
    let!(:donation) { create(:donation, non_profit:) }

    it 'returns the amount of donations' do
      expect(described_class.new(cause:).amount_free_donations).to eq(donation.value)
    end
  end

  describe '#amoun_free_donation_without_batches with amount 0' do
    let!(:cause) { create(:cause) }
    let!(:non_profit) { create(:non_profit, cause:) }
    let!(:donations) { create_list(:donation, 10, non_profit:) }
    let!(:donations2) { create_list(:donation, 10, non_profit:) }

    before do
      donations.each do |donation|
        create(:donation_batch, donation:)
      end
      donations2.each do |donation|
        create(:donation_blockchain_transaction, donation:)
      end
    end

    it 'returns the amount of donations' do
      expect(described_class.new(cause:).amount_free_donations_without_batch).to eq(0)
    end
  end

  describe '#amoun_free_donation_without_batches with amount > 0' do
    let!(:cause) { create(:cause) }
    let!(:non_profit) { create(:non_profit, cause:) }
    let!(:donations) { create_list(:donation, 10, non_profit:) }
    let!(:donations2) { create_list(:donation, 10, non_profit:) }
    let!(:sum) { donations.first.value * donations.count }

    before do
      donations2.each do |donation|
        create(:donation_blockchain_transaction, donation:)
      end
    end

    it 'returns the amount of donations' do
      expect(described_class.new(cause:).amount_free_donations_without_batch).to eq(sum)
    end
  end
end
