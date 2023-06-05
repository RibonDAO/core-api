require 'rails_helper'

RSpec.describe UserQueries, type: :model do
  describe '#last_contribution' do
    let(:user) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let(:last_contribution) { create(:person_payment, payer: customer, paid_date: Time.zone.now) }

    before do
      create_list(:person_payment, 2, payer: customer, paid_date: 1.day.ago)
      last_contribution
    end

    it 'returns the last contribution of the user' do
      expect(described_class.new(user:).last_contribution).to eq(last_contribution)
    end
  end

  describe '#months_active' do
    let(:user) { create(:user) }

    it "calculates the correct number of months between the current time and the user's last donation" do
      user.user_donation_stats.update(last_donation_at: 4.months.ago)

      expect(described_class.new(user:).months_active).to eq(4)
    end
  end

  describe '#total_donations_report' do
    let(:user) { create(:user) }

    it 'returns the correct number of donations for the user' do
      expect(described_class.new(user:).total_donations_report).to eq(user.donations.count)
    end
  end

  describe '.users_that_last_contributed_in' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let(:customer2) { create(:customer, user: user2) }

    before do
      create_list(:person_payment, 2, payer: customer, paid_date: 1.day.ago)
      create_list(:person_payment, 2, payer: customer2, paid_date: 5.days.ago)
    end

    it 'returns only the users that contributed lastly in the passed date' do
      expect(described_class.users_that_last_contributed_in(1.day.ago)).to eq([user])
    end
  end
end
