# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Service::Contributions::DonationContributionDeleteService, type: :service do
  subject(:service) do
    described_class.new(donation_contribution:)
  end

  let!(:contribution) { create(:contribution) }
  let!(:contribution_balance) { create(:contribution_balance, contribution:, tickets_balance_cents: 10) }
  let!(:donation) { create(:donation, value: 10) }
  let!(:donation_contribution) { create(:donation_contribution, contribution:, donation:) }

  describe '#delete' do
    it 'deletes a donation contribution' do
      expect { service.delete }.to change(DonationContribution, :count).by(-1)
    end

    it 'updates the contribution balance' do
      service.delete

      expect(contribution_balance.reload.tickets_balance_cents).to eq 20
    end
  end
end
