require 'rails_helper'

RSpec.describe Users::ResetDonationStreakJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now }

    let!(:users_donation_stats) { UserDonationStats.all }

    before do
      create_list(:user_donation_stats, 10, streak: 5, last_donation_at: 2.days.ago)
      perform_job
    end

    it 'update the streak to zero' do
      expect(users_donation_stats.pluck(:streak)).to eq([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
    end
  end
end
