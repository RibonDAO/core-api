require 'rails_helper'

RSpec.describe Service::Contributions::StatisticsService, type: :service do
  subject(:service) { described_class.new(contribution:) }
  
  include_context('when mocking a request') { let(:cassette_name) { 'conversion_rate_usd_brl' } }

  let(:cause) { create(:cause) }
  let(:person_payment) { create(:person_payment, usd_value_cents: 1_000, currency: 'brl') }
  let(:contribution) { create(:contribution, receiver: cause, person_payment:) }
  let(:donation) { create(:donation) }

  before do
    create(:ribon_config, contribution_fee_percentage: 20, minimum_contribution_chargeable_fee_cents: 10)
    create(:contribution_balance, contribution:, contribution_increased_amount_cents: 100,
                                  fees_balance_cents: 300, tickets_balance_cents: 300)
    create_list(:donation_contribution, 3, contribution:, donation:)
    create(:donation_contribution, contribution:)
    create_list(:contribution_fee, 3, payer_contribution: contribution, fee_cents: 100)
  end

  describe '#formatted_statistics' do
    it 'returns the necessary keys' do
      expect(service.formatted_statistics.keys)
        .to match_array(%i[initial_amount used_amount usage_percentage
                           remaining_amount total_tickets avg_donations_per_person
                           boost_amount total_increase_percentage total_amount_to_cause ribon_fee
                           boost_new_contributors boost_new_patrons total_donors total_contributors])
    end
  end

  describe '#initial_amount' do
    it 'returns the initial amount' do
      expect(service.initial_amount).to eq(10)
    end
  end

  describe '#used_amount' do
    it 'returns the used amount' do
      expect(service.used_amount).to eq(4)
    end
  end

  describe '#usage_percentage' do
    it 'returns the usage percentage' do
      expect(service.usage_percentage).to eq(40)
    end
  end

  describe '#remaining_amount' do
    it 'returns the remaining amount' do
      expect(service.remaining_amount).to eq(6)
    end
  end

  describe '#total_tickets' do
    it 'returns the total tickets' do
      expect(service.total_tickets).to eq(4)
    end
  end

  describe '#total_donors' do
    it 'returns the total donors' do
      expect(service.total_donors).to eq(2)
    end
  end

  describe '#avg_donations_per_person' do
    it 'returns the avg donations per person' do
      expect(service.avg_donations_per_person).to eq(2)
    end
  end

  describe '#boost_amount' do
    it 'returns the boost amount' do
      expect(service.boost_amount).to eq(1)
    end
  end

  describe '#total_increase_percentage' do
    it 'returns the total increase percentage' do
      expect(service.total_increase_percentage).to eq(10)
    end
  end

  describe '#total_amount_to_cause' do
    it 'returns the total amount to cause' do
      expect(service.total_amount_to_cause).to eq(8)
    end
  end

  describe '#ribon_fee' do
    it 'returns the ribon fee' do
      expect(service.ribon_fee).to eq(3)
    end
  end

  describe '#boost_new_contributors' do
    let!(:person_payment) { create(:person_payment, status: :paid, payer: create(:customer)) }
    let!(:new_contribution) { create(:contribution, receiver: cause, person_payment:) }

    before do
      create(:contribution_fee, payer_contribution: contribution, contribution: new_contribution)
    end

    it 'returns the new contributors generated' do
      expect(service.boost_new_contributors).to eq(1)
    end
  end

  describe '#boost_new_patrons' do
    let!(:person_payment) { create(:person_payment, status: :paid, payer: create(:big_donor)) }
    let!(:new_contribution) { create(:contribution, receiver: cause, person_payment:) }

    before do
      create(:contribution_fee, payer_contribution: contribution, contribution: new_contribution)
    end

    it 'returns the new patrons generated' do
      expect(service.boost_new_patrons).to eq(1)
    end
  end
end
