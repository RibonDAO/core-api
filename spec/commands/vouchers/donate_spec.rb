# frozen_string_literal: true

require 'rails_helper'

describe Vouchers::Donate do
  describe '.call' do
    subject(:command) { described_class.call(integration:, donation_command:, external_id:) }

    context 'when the voucher is valid' do
      let(:donation_command) { Donations::Donate.new(integration:, non_profit:, user:, platform:) }
      let(:external_id) { 'external_id' }
      let(:integration) { build(:integration, integration_webhook: build(:integration_webhook)) }
      let(:non_profit) { build(:non_profit) }
      let(:user) { build(:user) }
      let(:donation) { build(:donation) }
      let(:platform) { 'web' }
      let(:donation_command_double) { command_double(klass: Donations::Donate, result: donation) }

      before do
        allow(donation_command).to receive(:call).and_return(donation_command_double)
        allow(Vouchers::WebhookJob).to receive(:perform_later)
      end

      it 'returns success' do
        expect(command).to be_success
      end

      it 'calls the donation command' do
        command

        expect(donation_command).to have_received(:call)
      end

      it 'creates a voucher with correct params' do
        voucher = command.result

        expect(voucher).to be_an_instance_of Voucher
        expect(voucher.external_id).to eq external_id
        expect(voucher.integration).to eq integration
        expect(voucher.donation).to eq donation
      end

      it 'calls the voucher webhook with the voucher generated' do
        voucher = command.result

        expect(Vouchers::WebhookJob).to have_received(:perform_later).with(voucher)
      end
    end

    context 'when the voucher is invalid' do
      let(:donation_command) { Donations::Donate.new(integration:, non_profit:, user:, platform:) }
      let(:external_id) { nil }
      let(:integration) { build(:integration) }
      let(:non_profit) { build(:non_profit) }
      let(:user) { build(:user) }
      let(:donation) { build(:donation) }
      let(:platform) { 'web' }
      let(:donation_command_double) { command_double(klass: Donations::Donate, result: donation) }

      before do
        allow(donation_command).to receive(:call).and_return(donation_command_double)
      end

      it 'returns failure' do
        expect(command).to be_failure
      end

      it 'does not call the donation_command' do
        command

        expect(donation_command).not_to have_received(:call)
      end

      it 'does not create a voucher' do
        expect { command }.not_to change(Voucher, :count)
      end

      it 'returns an error message' do
        expect(command.errors).to eq({ message: [I18n.t('donations.invalid_voucher')] })
      end
    end
  end
end
