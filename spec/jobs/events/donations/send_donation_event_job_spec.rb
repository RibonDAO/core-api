require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe Events::Donations::SendDonationEventJob, type: :worker do
  describe '#perform' do
    subject(:worker) { described_class.new }

    let!(:user) { create(:user) }
    let!(:non_profit) { create(:non_profit, :with_impact) }
    let(:donation) { create(:donation, non_profit:, user:) }
    let(:normalizer_double) { instance_double(Impact::Normalizer) }
    let(:event_service_double) { instance_double(EventServices::SendEvent) }
    let(:job) { described_class }

    let(:event) do
      OpenStruct.new({
                       name: 'donated',
                       data: {
                         integration_id: donation.integration_id,
                         non_profit_id: donation.non_profit_id,
                         user_id: donation.user_id,
                         platform: donation.platform,
                         value: donation.value,
                         created_at: donation.created_at,
                         total_number_of_donations: donation.user.donations.count,
                         donation_impact: normalizer_double.normalize.join(' ')
                       }
                     })
    end

    before do
      create(:ribon_config)
      allow(job).to receive(:perform_later).with(donation:)
      allow(EventServices::SendEvent).to receive(:new).and_return(event_service_double)
      allow(event_service_double).to receive(:call)
      allow(Impact::Normalizer).to receive(:new).and_return(normalizer_double)
      allow(normalizer_double).to receive(:normalize).and_return(['10', '1 day of water', 'for 1 donor'])
    end

    context 'when it calls with donation params' do
      it 'calls the send event function with correct arguments' do
        job.perform_now(donation:)

        expect(EventServices::SendEvent).to have_received(:new).with(user: donation.user, event:)
      end
    end
  end
end
