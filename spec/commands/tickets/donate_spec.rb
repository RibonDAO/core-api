# frozen_string_literal: true

require 'rails_helper'

describe Tickets::Donate do
  describe '.call' do
    subject(:command) { described_class.call(integration:, non_profit:, user:, platform: 'web', quantity: 2) }

    include_context('when mocking a request') { let(:cassette_name) { 'sendgrid_email_api' } }

    context 'when no error occurs' do
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:user) { create(:user) }
      let(:ticket_labeling_instance) { instance_double(Service::Contributions::TicketLabelingService) }

      before do
        create(:chain)
        create_list(:ticket, 2, user:, integration:)
        allow(Donations::SetUserLastDonationAt).to receive(:call)
          .and_return(command_double(klass: Donations::SetUserLastDonationAt))
        allow(Donations::SetLastDonatedCause).to receive(:call)
          .and_return(command_double(klass: Donations::SetLastDonatedCause))
        allow(Service::Contributions::TicketLabelingService).to receive(:new)
          .and_return(ticket_labeling_instance)
        allow(ticket_labeling_instance).to receive(:label_donation)
        create(:ribon_config, default_ticket_value: 100)
      end

      it 'creates a donation in database' do
        expect { command }.to change(Donation, :count).by(2) && change(Ticket, :count).by(-2)
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

      it 'calls the ticket_labeling_instance label donation function' do
        command

        expect(ticket_labeling_instance).to have_received(:label_donation)
      end

      it 'returns the donation created' do
        expect(command.result).to eq user.donations.order(created_at: :desc).limit(2)
      end
    end

    context 'when an error occurs at the validation process' do
      let(:integration) { build(:integration) }
      let(:non_profit) { build(:non_profit) }
      let(:user) { build(:user) }

      before do
        create(:chain)
        create(:ribon_config, default_ticket_value: 100)
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
  end
end
