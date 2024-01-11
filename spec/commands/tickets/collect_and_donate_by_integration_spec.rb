# frozen_string_literal: true

require 'rails_helper'

describe Tickets::CollectAndDonateByIntegration do
  describe '.call' do
    subject(:command) { described_class.call(integration:, user:, platform: 'web', non_profit:) }

    context 'when no error occurs' do
      let(:integration) { create(:integration) }
      let(:non_profit) { create(:non_profit, :with_impact) }
      let(:user) { create(:user) }
      let(:command_stubbed) { class_double(Tickets::ClearCollectedByIntegrationJob) }

      before do
        create(:chain)
        create(:ribon_config, default_ticket_value: 100)
        allow(Tickets::ClearCollectedByIntegrationJob).to receive(:set).and_return(command_stubbed)
        allow(command_stubbed).to receive(:perform_later)
      end

      it 'calls the Tickets::CollectAndDonateByIntegration' do
        allow(described_class).to receive(:call).with(integration:, user:,
                                                      platform: 'web', non_profit:)
        command

        expect(described_class)
          .to have_received(:call).with(integration:, user:, platform: 'web', non_profit:)
      end

      it 'creates a donation in database' do
        expect { command }.to change(Donation, :count).by(1)
      end

      it 'returns the donation created' do
        expect(command.result).to match_array(user.donations.order(created_at: :desc).limit(2))
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

      it 'returns an error' do
        expect(command.errors).to be_present
      end
    end
  end
end
