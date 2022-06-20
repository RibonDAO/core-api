# frozen_string_literal: true

require 'rails_helper'

describe Donations::Donate do
  describe '.call' do
    subject(:command) { described_class.call(integration:, non_profit:, user:) }

    context 'when no error occurs' do
      let(:integration) { build(:integration) }
      let(:non_profit) { build(:non_profit) }
      let(:user) { build(:user) }
      let(:donation) { build(:donation, created_at: DateTime.parse('2021-01-12 10:00:00')) }

      before do
        allow(Donation).to receive(:create!).and_return(donation)
        allow(Web3::RibonContract).to receive(:donate_through_integration).and_return(
          { 'body' => {
            transactionHash: '0xFF20'
          }.to_json }
        )
        allow(Donations::SetUserLastDonationAt)
          .to receive(:call)
          .and_return(command_double(klass: Donations::SetUserLastDonationAt))
        allow(donation).to receive(:save)
        create(:ribon_config, default_ticket_value: 100)
      end

      it 'creates a donation in database' do
        command

        expect(Donation).to have_received(:create!).with(integration:, non_profit:,
                                                         user:, value: 100)
      end

      it 'calls the donation in contract' do
        command

        expect(Web3::RibonContract)
          .to have_received(:donate_through_integration)
          .with(amount: 1_000_000_000_000_000_000,
                non_profit_address: non_profit.wallet_address,
                user_email: user.email)
      end

      it 'calls the Donations::SetUserLastDonationAt' do
        command

        expect(Donations::SetUserLastDonationAt)
          .to have_received(:call).with(user:, date_to_set: donation.created_at)
      end

      it 'returns the donation hash in blockchain' do
        expect(command.result).to eq '0xFF20'
      end
    end

    context 'when an error occurs at the blockchain process' do
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit) }
      let(:user) { create(:user) }

      before do
        create(:ribon_config, default_ticket_value: 100)
        allow(Web3::RibonContract).to receive(:donate_through_integration)
          .and_raise(StandardError.new('error message'))
      end

      it 'does not create the donation on the database' do
        expect { command }.not_to change(Donation, :count)
      end

      it 'returns nil' do
        expect(command.result).to be_nil
      end

      it 'returns error message' do
        expect(command.errors[:message]).to eq ['error message']
      end
    end
  end
end
