require 'rails_helper'

describe Givings::Subscriptions::CreateDirectTransferSubscription do
  include ActiveJob::TestHelper

  describe '.call' do
    subject(:command) { described_class.new(args).call }

    include_context('when mocking a request') { let(:cassette_name) { 'stripe_payment_method' } }

    context 'when it has the correct params' do
      let(:integration) { create(:integration) }
      let(:offer) { create(:offer) }
      let(:args) do
        { email: 'user@test.com', offer:, integration_id: integration.id }
      end

      it 'creates a subscription' do
        create(:plan, offer:)

        expect { command }.to change(Subscription, :count).by(1)
      end

      it 'schedules the job to give monthly tickets' do
        create(:plan, offer:)

        expect { command }.to have_enqueued_job(Tickets::GenerateClubMonthlyTicketsJob)
      end

      it 'schedules the job to give daily tickets' do
        create(:plan, offer:)

        expect { command }.to have_enqueued_job(Tickets::GenerateClubDailyTicketsJob)
      end
    end

    context 'when subscription already exists' do
      let(:integration) { create(:integration) }
      let(:offer) { create(:offer) }
      let(:args) do
        { email: 'user@test.com', offer:, integration_id: integration.id }
      end

      it 'does not create a new one' do
        create(:subscription, payer: create(:customer, user: create(:user, email: 'user@test.com')),
                              status: :active)

        expect { command }.not_to change(Subscription, :count)
      end
    end
  end
end
