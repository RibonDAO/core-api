# frozen_string_literal: true

require 'rails_helper'

describe Donations::Donate do
  describe '.call' do
    subject(:command) { described_class.call(integration:, non_profit:, user:, platform: 'web') }

    include_context('when mocking a request') { let(:cassette_name) { 'sendgrid_email_api' } }

    context 'when no error occurs' do
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:user) { create(:user) }

      before do
        create(:chain)
        allow(Donations::SetUserLastDonationAt).to receive(:call)
          .and_return(command_double(klass: Donations::SetUserLastDonationAt))
        allow(Donations::SetLastDonatedCause).to receive(:call)
          .and_return(command_double(klass: Donations::SetLastDonatedCause))
        create(:ribon_config, default_ticket_value: 100)
      end

      it 'creates a donation in database' do
        expect { command }.to change(Donation, :count).by(1)
      end

      it 'calls the Donations::SetUserLastDonationAt' do
        command

        expect(Donations::SetUserLastDonationAt)
          .to have_received(:call).with(user:, date_to_set: user.donations.last.created_at)
      end

      it 'calls the Donations::SetLastDonatedCause' do
        command

        expect(Donations::SetLastDonatedCause)
          .to have_received(:call).with(user:, cause: non_profit.cause)
      end

      it 'returns the donation created' do
        expect(command.result).to eq user.donations.last
      end
    end

    context 'when an error occurs at the validation process' do
      let(:integration) { build(:integration) }
      let(:non_profit) { build(:non_profit) }
      let(:user) { build(:user) }
      let(:donation) { build(:donation) }

      before do
        allow(Donation).to receive(:create!).and_return(donation)
        allow(Donations::SetUserLastDonationAt).to receive(:call)
          .and_return(command_double(klass: Donations::SetUserLastDonationAt))
        allow(donation).to receive(:save)
        allow(user).to receive(:can_donate?).and_return(false)
      end

      it 'does not create the donation on the database' do
        expect { command }.not_to change(Donation, :count)
      end

      it 'returns nil' do
        expect(command.result).to be_nil
      end

      it 'returns an error' do
        expect(command.errors).to be_present
      end

      it 'returns an error message' do
        expect(command.errors[:message]).to eq ['Unable to donate now. Wait for your next donation.']
      end
    end

    context 'when user does not exist on database' do
      let(:integration) { build(:integration) }
      let(:non_profit) { build(:non_profit) }
      let(:user) { nil }
      let(:donation) { build(:donation) }

      before do
        allow(Donation).to receive(:create!).and_return(donation)
        allow(Donations::SetUserLastDonationAt).to receive(:call)
          .and_return(command_double(klass: Donations::SetUserLastDonationAt))
        allow(donation).to receive(:save)
      end

      it 'does not create the donation on the database' do
        expect { command }.not_to change(Donation, :count)
      end

      it 'returns nil' do
        expect(command.result).to be_nil
      end

      it 'returns an error' do
        expect(command.errors).to be_present
      end

      it 'returns an error message' do
        expect(command.errors[:message]).to eq ['User not found. Please logout and try again.']
      end
    end

    context 'when integration does not exist on database' do
      let(:integration) { nil }
      let(:non_profit) { build(:non_profit) }
      let(:user) { build(:user) }
      let(:donation) { build(:donation) }

      before do
        allow(Donation).to receive(:create!).and_return(donation)
        allow(Donations::SetUserLastDonationAt).to receive(:call)
          .and_return(command_double(klass: Donations::SetUserLastDonationAt))
        allow(donation).to receive(:save)
        allow(user).to receive(:can_donate?).and_return(false)
      end

      it 'does not create the donation on the database' do
        expect { command }.not_to change(Donation, :count)
      end

      it 'returns nil' do
        expect(command.result).to be_nil
      end

      it 'returns an error' do
        expect(command.errors).to be_present
      end

      it 'returns an error message' do
        expect(command.errors[:message]).to eq ['Integration not found. Please reload the page and try again.']
      end
    end

    context 'when non profit does not exist on database' do
      let(:integration) { build(:integration) }
      let(:non_profit) { nil }
      let(:user) { build(:user) }
      let(:donation) { build(:donation) }

      before do
        allow(Donation).to receive(:create!).and_return(donation)
        allow(Donations::SetUserLastDonationAt).to receive(:call)
          .and_return(command_double(klass: Donations::SetUserLastDonationAt))
        allow(donation).to receive(:save)
        allow(user).to receive(:can_donate?).and_return(false)
      end

      it 'does not create the donation on the database' do
        expect { command }.not_to change(Donation, :count)
      end

      it 'returns nil' do
        expect(command.result).to be_nil
      end

      it 'returns an error' do
        expect(command.errors).to be_present
      end

      it 'returns an error message' do
        expect(command.errors[:message]).to eq ['NGO not found. Please reload the page and try again.']
      end
    end

    context 'when the user cannot donate but the skip_allowance is passed' do
      subject(:command) do
        described_class.call(integration:, non_profit:, user:, platform: 'web', skip_allowance:)
      end

      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:user) { create(:user) }
      let(:skip_allowance) { true }

      before do
        create(:chain)
        create(:ribon_config, default_ticket_value: 100)
        allow(Donations::SetUserLastDonationAt)
          .to receive(:call).and_return(command_double(klass: Donations::SetUserLastDonationAt))
        allow(user).to receive(:can_donate?).and_return(false)
      end

      it 'creates the donation on the database' do
        expect { command }.to change(Donation, :count).by(1)
      end

      it 'returns a donation' do
        expect(command.result).to be_an_instance_of(Donation)
      end

      it 'returns success' do
        expect(command.success?).to be_truthy
      end
    end

    context 'when the pool balance is zero' do
      let(:integration) { create(:integration) }
      let!(:cause) { create(:cause) }
      let!(:pool) { create(:pool, cause:) }
      let(:non_profit) { create(:non_profit, cause:) }
      let(:user) { create(:user) }

      before do
        create(:chain)
        create(:ribon_config)
        create(:pool_balance, pool:, balance: 0)
        allow(user).to receive(:can_donate?).and_return(true)
      end

      it 'does not create the donation on the database' do
        expect { command }.not_to change(Donation, :count)
      end

      it 'returns nil' do
        expect(command.result).to be_nil
      end

      it 'returns an error' do
        expect(command.errors).to be_present
      end

      it 'returns an error message' do
        expect(command.errors[:message]).to eq ['Unable to donate now. Wait for your next donation.']
      end
    end
  end
end
