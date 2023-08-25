# frozen_string_literal: true

require 'rails_helper'

describe Contributions::CreateContribution do
  include ActiveStorage::Blob::Analyzable
  include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_brl_usd_and_gas_fee' } }

  let(:receiver) { create(:cause) }
  let(:payment) { create(:person_payment, receiver:, liquid_value_cents: 1000) }
  let(:command) { described_class.call(payment:) }
  let(:contribution_fee_service_instance) { instance_double(ContributionServices::FeesLabeling) }

  describe '#call' do
    before do
      allow(ContributionServices::FeesLabeling).to receive(:new)
        .and_return(contribution_fee_service_instance)
      allow(contribution_fee_service_instance).to receive(:spread_fee_to_payers)
      allow(Reporter).to receive(:log)
      create(:ribon_config, contribution_fee_percentage: 20)
    end

    context 'when the contribution is successfully created' do
      it 'creates a new contribution with the correct attributes' do
        expect { command }.to change(Contribution, :count).by(1)
        contribution = Contribution.last
        expect(contribution.person_payment).to eq(payment)
        expect(contribution.receiver).to eq(receiver)
      end

      context 'when the receiver is a non profit' do
        let(:receiver) { create(:non_profit) }

        it 'does not set the contribution balance' do
          command
          contribution = Contribution.last

          expect(contribution.contribution_balance).to be_nil
        end
      end

      it 'sets the contribution balance' do
        command
        contribution = Contribution.last

        expect(contribution.contribution_balance).to be_present
      end
    end

    context 'when an error occurs' do
      before do
        allow(Contribution).to receive(:create!)
          .and_raise(StandardError.new('error message'))
      end

      it 'does not create a new contribution' do
        expect { command }.not_to change(Contribution, :count)
      end

      it 'adds an error message to the command' do
        command

        expect(command.errors[:message]).to include('error message')
      end

      it 'logs the error' do
        command

        expect(Reporter).to have_received(:log).with(error: an_instance_of(StandardError))
      end
    end
  end
end
