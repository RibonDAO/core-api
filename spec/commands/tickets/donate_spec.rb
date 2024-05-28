# frozen_string_literal: true

require 'rails_helper'

describe Tickets::Donate do
  describe '.call' do
    subject(:command) { described_class.call(non_profit:, user:, platform: 'web', quantity: 2, integration_only:) }

    let(:integration_only) { false }

    context 'when no error occurs' do
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:user) { create(:user) }
      let(:ticket_labeling_instance) { instance_double(Service::Contributions::TicketLabelingService) }

      before do
        create(:chain)
        create_list(:ticket, 2, user:, integration:)
        allow(Service::Contributions::TicketLabelingService).to receive(:new)
          .and_return(ticket_labeling_instance)
        allow(ticket_labeling_instance).to receive(:label_donation)
        create(:ribon_config, default_ticket_value: 100)
      end

      it 'creates a donation in database' do
        expect { command }.to change(Donation, :count).by(2) && change(Ticket, :count).by(-2)
      end

      it 'calls the ticket_labeling_instance label donation function' do
        command

        expect(ticket_labeling_instance).to have_received(:label_donation).twice
      end

      it 'calls the associate_integration_vouchers method' do
        command_instance = described_class.new(non_profit:, user:, platform: 'app', quantity: 2, integration_only:)
        allow(command_instance).to receive(:associate_integration_vouchers)

        command_instance.call

        expect(command_instance).to have_received(:associate_integration_vouchers)
      end

      it 'returns the donation created' do
        expect(command.result).to match_array(user.donations.order(created_at: :desc).limit(2))
      end
    end

    context 'when the ticket donated has an external_id' do
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:user) { create(:user) }
      let!(:voucher1) { create(:voucher, external_id: '28392', integration:) }
      let!(:voucher2) { create(:voucher, external_id: '28393', integration:) }

      before do
        create(:chain)
        create(:ticket, user:, integration:, external_id: '28392')
        create(:ticket, user:, integration:, external_id: '28393')
        create(:integration_webhook, integration:)
        create(:ribon_config, default_ticket_value: 100)
        allow(Vouchers::WebhookJob).to receive(:perform_later)
      end

      it 'creates a donation in database' do
        expect { command }.to change(Donation, :count).by(2)
      end

      it 'destroy a ticket' do
        expect { command }.to change(Ticket, :count).by(-2)
      end

      it 'calls the WebhookJob 2 times' do
        command
        expect(Vouchers::WebhookJob)
          .to have_received(:perform_later).with(voucher1)
        expect(Vouchers::WebhookJob)
          .to have_received(:perform_later).with(voucher2)
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

    context 'when tickets have external ids' do
      let(:user) { create(:user) }
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:donation) { create(:donation) }
      let(:integration) { create(:integration) }

      before do
        create(:ribon_config, default_ticket_value: 100)
        create(:ticket, user:, integration:, external_id: 'external_id1')
        create(:ticket, user:, integration:, external_id: 'external_id2')
        create(:voucher, external_id: 'external_id1', donation: nil)
        create(:voucher, external_id: 'external_id2', donation: nil)
      end

      it 'updates vouchers donations' do
        command

        donations = Donation.last(2)
        vouchers = Voucher.where(external_id: %w[external_id1 external_id2])

        expect(vouchers.pluck(:donation_id)).to match_array([donations.first.id, donations.second.id])
      end
    end

    context 'when integration_only param is true and you not have enough tickets' do
      let(:user) { create(:user) }
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:donation) { create(:donation) }
      let(:integration) { create(:integration) }
      let(:integration_only) { true }

      before do
        create(:ribon_config, default_ticket_value: 100)
        create(:ticket, user:, integration:, source: 'integration')
        create(:ticket, user:, integration:, source: 'club')
      end

      it 'does not donate any ticket' do
        expect { command }.to change(Donation, :count).by(0)
      end
    end

    context 'when integration_only param is false' do
      let(:user) { create(:user) }
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:donation) { create(:donation) }
      let(:integration) { create(:integration) }
      let(:integration_only) { false }

      before do
        create(:ribon_config, default_ticket_value: 100)
        create(:ticket, user:, integration:, source: 'integration')
        create(:ticket, user:, integration:, source: 'club')
      end

      it 'donates all tickets' do
        expect { command }.to change(Donation, :count).by(2)
      end
    end
  end
end
