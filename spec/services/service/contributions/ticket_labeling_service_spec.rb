require 'rails_helper'

RSpec.describe Service::Contributions::TicketLabelingService, type: :service do
  subject(:service) { described_class.new(donation:) }

  let(:cause) { create(:cause) }
  let(:non_profit) { create(:non_profit, cause:) }
  let(:donation) { create(:donation, non_profit:) }
  let(:contribution) { create(:contribution, :with_contribution_balance, receiver: cause) }

  before do
    create(:ribon_config, contribution_fee_percentage: 20, minimum_contribution_chargeable_fee_cents: 10)
  end

  describe '#label_donation' do
    before do
      mock_command(klass: Contributions::Labeling::DetermineChosenContribution, result: contribution)
    end

    it 'creates a donation contribution' do
      expect { service.label_donation }.to change(DonationContribution, :count).by(1)
    end

    it 'labels the donation with the chosen contribution' do
      service.label_donation

      expect(DonationContribution.last.contribution).to eq(contribution)
    end

    it 'updates the contribution balance of the chosen contribution' do
      expect { service.label_donation }
        .to change(contribution.contribution_balance, :tickets_balance_cents).by(-donation.value)
    end
  end
end
