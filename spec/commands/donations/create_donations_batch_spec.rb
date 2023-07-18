# frozen_string_literal: true

require 'rails_helper'

describe Donations::CreateDonationsBatch do
  describe '.call' do
    subject(:command) { described_class.new(integration:, non_profit:, period:) }

    include_context('when mocking a request') { let(:cassette_name) { 'create_donations_batch' } }

    let(:integration) { create(:integration) }
    let(:non_profit) { create(:non_profit) }
    let(:period) { Time.zone.today.at_beginning_of_month }
    let(:last_month) { 1.month.ago.to_date.at_beginning_of_month }
    let(:batch) { create(:batch) }
    let(:batch_file) { File.read("#{Rails.root}/app/lib/web3/utils/donation_batch.json") }
    let(:ntf_storage) { Web3::Storage::NftStorage::Actions.new }
    let(:ntf_storage_base) { Web3::Storage::NftStorage::Base.new }
    let(:result) { Web3::Storage::NftStorage::Actions.new.store(file: batch_file) }
    let!(:last_month_donation) { create(:donation, integration:, non_profit:, created_at: last_month) }

    before do
      create(:donation, integration:, non_profit:)
      allow(ntf_storage).to receive(:store)
      allow(ntf_storage_base).to receive(:store)
    end

    it 'creates a batch in database' do
      expect { command.call }.to change(Batch, :count).by(1)
    end

    it 'creates a batch in database with the correct reference period' do
      command.call
      expect(Batch.last.reference_period).to eq(period)
    end

    it 'creates a donation_batch in database' do
      expect { command.call }.to change(DonationBatch, :count).by(1)
    end

    it 'creates a donation_batch for donation from period month' do
      command.call
      expect(DonationBatch.last.donation.created_at).to be_between(period, period.end_of_month)
    end

    it 'does not create a donation_batch for donation from last month' do
      command.call
      expect(last_month_donation.donation_batch).to be_nil
    end
  end
end
