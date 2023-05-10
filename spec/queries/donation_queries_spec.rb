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

  describe '#amount_free_donations_without_batches' do
    let!(:cause) { create(:cause) }
    let!(:non_profit) { create(:non_profit, cause:) }
    let!(:donations) { create_list(:donation, 10, non_profit:) }
    let!(:donations2) { create_list(:donation, 10, non_profit:) }

    before do
      donations2.each do |donation|
        create(:donation_blockchain_transaction, donation:)
      end
    end

    describe 'with donation batches' do
      before do
        donations.each do |donation|
          create(:donation_batch, donation:)
        end
      end

      it 'returns 0' do
        expect(described_class.new(cause:).amount_free_donations_without_batch).to eq(0)
      end
    end

    describe 'without donation batches' do
      let!(:sum) { donations.first.value * donations.count }

      it 'returns the amount of donations' do
        expect(described_class.new(cause:).amount_free_donations_without_batch).to eq(sum)
      end
    end

    describe 'with blockchain transaction processing' do
      let!(:sum) { donations.first.value * donations.count }

      before do
        donations.each do |donation|
          create(:donation_batch, donation:)
          create(:blockchain_transaction, owner: donation.donation_batch.batch, status: :processing)
        end
      end

      it 'returns the amount of donations' do
        expect(described_class.new(cause:).amount_free_donations_without_batch).to eq(sum)
      end
    end

    describe 'with blockchain transaction success' do
      before do
        donations.each do |donation|
          create(:donation_batch, donation:)
          create(:blockchain_transaction, owner: donation.donation_batch.batch, status: :success)
        end
      end

      it 'returns 0' do
        expect(described_class.new(cause:).amount_free_donations_without_batch).to eq(0)
      end
    end
  end
end
