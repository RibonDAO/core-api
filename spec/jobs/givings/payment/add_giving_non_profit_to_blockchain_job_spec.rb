require 'rails_helper'

RSpec.describe Givings::Payment::AddGivingNonProfitToBlockchainJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(amount:, payment:, non_profit:) }

    let(:result) { '0xFC02' }
    let(:amount) { 0.5 }
    let(:payment) { create(:person_payment) }
    let(:klass) { Givings::NonProfitTreasure::AddBalance }
    let(:non_profit) { build(:non_profit) }

    before do
      allow(Givings::NonProfitTreasure::AddBalance)
        .to receive(:call).and_return(command_double(klass:, result:))
      perform_job
    end

    it 'calls the Givings::NonProfitTreasure::AddBalance with right params' do
      expect(klass).to have_received(:call).with(amount:, non_profit:)
    end

    it 'creates a person_blockchain_transaction to the payment with correct params' do
      expect(payment.person_blockchain_transaction.treasure_entry_status).to eq 'processing'
      expect(payment.person_blockchain_transaction.transaction_hash).to eq result
    end
  end
end
