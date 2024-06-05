require 'rails_helper'

RSpec.describe Users::UpdateDaysDonatingForAllJob, type: :job do
  subject(:perform_job) { described_class.perform_now }

  let(:redis_key) { 'LAST_UPDATE_USER_ID_KEY' }

  describe 'when user has donated on multiple different days' do
    let(:user) { create(:user) }

    before do
      create(:donation, created_at: Time.zone.now.advance(days: -1), user:)
      create(:donation, created_at: Time.zone.now.advance(days: -2), user:)
      create(:donation, created_at: Time.zone.now.advance(days: -3), user:)

      allow(RedisStore::HStore).to receive(:get).and_return(nil)
      allow(RedisStore::HStore).to receive(:set)
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

      allow(RedisStore::HStore).to receive(:get).and_return(nil)
      allow(RedisStore::HStore).to receive(:set)
    end

    it 'updates days donating to 2' do
      expect { perform_job }.to change { user.user_donation_stats.reload.days_donating }.from(0).to(2)
    end
  end

  describe 'when user has not donated' do
    let(:user) { create(:user) }

    before do
      allow(RedisStore::HStore).to receive(:get).and_return(nil)
      allow(RedisStore::HStore).to receive(:set)
    end

    it 'does not change days donating' do
      expect { perform_job }.not_to change { user.user_donation_stats.reload.days_donating }
    end
  end

  describe 'when there is a last_user cache' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    before do
      create(:donation, created_at: Time.zone.now.advance(days: -1), user: user1)
      create(:donation, created_at: Time.zone.now.advance(days: -2), user: user2)
      create(:donation, created_at: Time.zone.now.advance(days: -2), user: user2)

      allow(RedisStore::HStore).to receive(:get).and_return(user1.id)
      allow(RedisStore::HStore).to receive(:set)
    end

    it 'doesnt update the cached user' do
      expect { perform_job }
        .not_to change { user1.user_donation_stats.reload.days_donating }
    end

    it 'updates the non cached user' do
      expect { perform_job }
        .to change { user2.user_donation_stats.reload.days_donating }
    end

    it 'saver the last user id' do
      perform_job
      expect(RedisStore::HStore)
        .to have_received(:set).with(key: redis_key, value: user2.id)
    end
  end
end
