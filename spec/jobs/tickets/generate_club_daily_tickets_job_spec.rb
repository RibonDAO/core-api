require 'rails_helper'

RSpec.describe Tickets::GenerateClubDailyTicketsJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(user, platform, quantity, integration) }

    let(:integration) { create(:integration) }
    let(:user) { create(:user) }
    let(:platform) { 'app' }
    let(:quantity) { 2 }
    let(:plan) { create(:plan, daily_tickets: 2) }
    let(:offer) { create(:offer, plans: [plan]) }
    let(:command) { Tickets::GenerateClubTickets }

    before do
      allow(command).to receive(:call)
      create(:subscription, payer: user, integration:, status: :active, platform:,
                            offer:)
      perform_job
    end

    it 'calls GenerateClubTickets' do
      expect(command).to have_received(:call).with(user:, platform:, quantity:,
                                                   category: :daily, integration:)
    end
  end
end
