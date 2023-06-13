require 'rails_helper'

RSpec.describe Service::Integrations::ImpactTrend, type: :service do
  subject(:impact_trend_service) { described_class.new(start_date:, end_date:, integration:) }

  before do
    allow(Service::Integrations::Impact).to receive(:new).and_return(previous_impact_service)
    allow(Service::Integrations::Impact)
      .to receive(:new).with(integration:, start_date:, end_date:).and_return(impact_service)
  end

  let(:impact_service) do
    instance_double(Service::Integrations::Impact, {
                      total_donations: 10,
                      total_donors: 6,
                      total_new_donors: 2,
                      total_donors_recurrent: 4,
                      impact_per_non_profit: [],
                      donations_per_non_profit: [],
                      donors_per_non_profit: [],
                      donations_splitted_into_intervals: [],
                      donors_splitted_into_intervals: []
                    })
  end
  let(:previous_impact_service) do
    instance_double(Service::Integrations::Impact, {
                      total_donations: 5,
                      total_donors: 3,
                      total_new_donors: 1,
                      total_donors_recurrent: 2,
                      impact_per_non_profit: [],
                      donations_per_non_profit: [],
                      donors_per_non_profit: [],
                      donations_splitted_into_intervals: [],
                      donors_splitted_into_intervals: []
                    })
  end
  let(:integration) { build(:integration) }
  let(:start_date) { 3.days.ago }
  let(:end_date) { 1.day.ago }

  describe '#formatted_impact' do
    subject(:method) { impact_trend_service.formatted_impact }

    it 'returns current impact' do
      expect(method).to include(impact_per_non_profit: [])
      expect(method).to include(donations_per_non_profit: [])
      expect(method).to include(donors_per_non_profit: [])
      expect(method).to include(donations_splitted_into_intervals: [])
      expect(method).to include(donors_splitted_into_intervals: [])
    end

    it 'returns previous impact' do
      expect(method).to include(previous_total_donations: 5)
      expect(method).to include(previous_total_donors: 3)
      expect(method).to include(previous_impact_per_non_profit: [])
      expect(method).to include(previous_donations_per_non_profit: [])
      expect(method).to include(previous_donors_per_non_profit: [])
      expect(method).to include(previous_donations_splitted_into_intervals: [])
      expect(method).to include(previous_donors_splitted_into_intervals: [])
    end

    it 'returns impact balance' do
      expect(method).to include(total_donations: 10)
      expect(method).to include(total_donors: 6)
      expect(method).to include(total_new_donors: 2)
      expect(method).to include(total_donors_recurrent: 4)
      expect(method).to include(total_donations_balance: 5)
      expect(method).to include(total_donors_balance: 3)
      expect(method).to include(total_donations_trend: 100.0)
      expect(method).to include(total_donors_trend: 100.0)
    end

    it 'returns correct hash length' do
      expect(method.size).to eq(20)
    end
  end
end
