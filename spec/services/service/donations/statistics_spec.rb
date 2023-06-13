require 'rails_helper'

RSpec.describe Service::Donations::Statistics, type: :service do
  subject(:service) { described_class.new(donations:) }

  let(:user) { create(:user) }
  let(:user2) { create(:user, created_at: 10.days.ago) }
  let(:donations) { Donation.all }
  let(:non_profit1) { create(:non_profit) }
  let(:non_profit2) { create(:non_profit) }

  before do
    travel_to Time.zone.local(2023, 1, 1, 12, 0, 0)

    create(:non_profit_impact, usd_cents_to_one_impact_unit: 10,
                               non_profit: non_profit1, start_date: 1.day.ago, end_date: 1.day.from_now)
    create(:non_profit_impact, usd_cents_to_one_impact_unit: 10,
                               non_profit: non_profit2, start_date: 1.day.ago, end_date: 1.day.from_now)
    create_list(:donation, 2, value: 10, user:, non_profit: non_profit1)
    create_list(:donation, 2, value: 10, user: user2, non_profit: non_profit1)
    create(:donation, value: 10, user:, non_profit: non_profit2)
    create(:donation, value: 10, user: user2, non_profit: non_profit2)
  end

  describe '#total_donations' do
    it 'returns the total donations count' do
      expect(service.total_donations).to eq 6
    end
  end

  describe '#total_donors' do
    it 'returns the total donors count' do
      expect(service.total_donors).to eq 2
    end
  end

  describe '#total_new_donors' do
    it 'returns the total donors count' do
      expect(service.total_new_donors).to eq 1
    end
  end

  describe '#total_donors_recurrent' do
    it 'returns the total donors count' do
      expect(service.total_donors_recurrent).to eq 1
    end
  end

  describe '#impact_per_non_profit' do
    it 'returns the impact value per non profit' do
      expect(service.impact_per_non_profit.first[:impact]).to eq 4
      expect(service.impact_per_non_profit.second[:impact]).to eq 2
      expect(service.impact_per_non_profit.first[:non_profit].name).to eq non_profit1.name
      expect(service.impact_per_non_profit.second[:non_profit].name).to eq non_profit2.name
    end
  end

  describe '#donors_per_non_profit' do
    it 'returns the donors count per non profit' do
      expect(service.donors_per_non_profit.first[:donors]).to eq 2
      expect(service.donors_per_non_profit.second[:donors]).to eq 2
      expect(service.donors_per_non_profit.first[:non_profit].name).to eq non_profit1.name
      expect(service.donors_per_non_profit.second[:non_profit].name).to eq non_profit2.name
    end
  end

  describe '#donations_splitted_into_intervals' do
    it 'returns the donations count splitted into intervals' do
      expect(service.donations_splitted_into_intervals.first[:count]).to eq 6
      expect(service.donations_splitted_into_intervals.first[:initial_date]).to eq(
        Time.zone.today.strftime('%d/%m/%Y')
      )
    end
  end

  describe '#donors_splitted_into_intervals' do
    it 'returns the donors count splitted into intervals' do
      expect(service.donors_splitted_into_intervals.first[:count]).to eq 2
      expect(service.donors_splitted_into_intervals.first[:initial_date]).to eq(
        Time.zone.today.strftime('%d/%m/%Y')
      )
    end
  end
end
