require 'rails_helper'

RSpec.describe Givings::Payment::AddGivingCauseToBlockchainJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(amount:, payment:, pool:) }

    let(:result) { '0xFC02' }
    let(:amount) { 0.5 }
    let(:feeable) { true }
    let(:payment) { create(:person_payment) }
    let(:klass) { Givings::CommunityTreasure::AddBalance }
    let(:pool) { build(:pool) }

    before do
      allow(Givings::CommunityTreasure::AddBalance)
        .to receive(:call).and_return(command_double(klass:, result:))
      perform_job
    end

    it 'calls the Givings::CommunityTreasure::AddBalance with right params' do
      expect(klass).to have_received(:call).with(amount:, feeable:, pool:)
    end

    it 'creates a person_blockchain_transaction to the payment with correct params' do
      expect(payment.person_blockchain_transaction.treasure_entry_status).to eq 'processing'
      expect(payment.person_blockchain_transaction.transaction_hash).to eq result
    end
  end
end
