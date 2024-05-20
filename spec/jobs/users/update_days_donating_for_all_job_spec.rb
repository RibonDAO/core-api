require 'rails_helper'

RSpec.describe Users::UpdateDaysDonatingForAllJob, type: :job do
  subject(:perform_job) { described_class.perform_now }

  describe 'when user has donated on multiple different days' do
    let(:user) { create(:user) }

    before do
      create(:donation, created_at: Time.zone.now.advance(days: -1), user:)
      create(:donation, created_at: Time.zone.now.advance(days: -2), user:)
      create(:donation, created_at: Time.zone.now.advance(days: -3), user:)
    end

    it 'updates days donating to 3' do
      expect { perform_job }.to change { user.user_donation_stats.reload.days_donating }.from(0).to(3)
    end
  end

  describe 'when user has donated on multiple of the same days' do
    let(:user) { create(:user) }

    before do
      create(:donation, created_at: Time.zone.now.advance(days: -1), user:)
      create(:donation, created_at: Time.zone.now.advance(days: -2), user:)
      create(:donation, created_at: Time.zone.now.advance(days: -2), user:)
    end

    it 'updates days donating to 2' do
      expect { perform_job }.to change { user.user_donation_stats.reload.days_donating }.from(0).to(2)
    end
  end

  describe 'when user has not donated' do
    let(:user) { create(:user) }

    it 'does not change days donating' do
      expect { perform_job }.not_to change { user.user_donation_stats.reload.days_donating }
    end
  end
end
