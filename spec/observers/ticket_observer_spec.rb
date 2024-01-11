require 'rails_helper'

RSpec.describe TicketObserver, type: :observer do
  describe 'if a ticket is created' do
    let(:user) { create(:user) }
    let(:ticket) { build(:ticket, user:) }
    let(:key) { "tickets-#{user.id}" }

    before do
      allow(RedisStore::HStore).to receive(:get).with(key:).and_return(1)
      allow(RedisStore::HStore).to receive(:set)
    end

    it 'updates cached tickets' do
      ticket.save
      expect(RedisStore::HStore).to have_received(:get).with(key:)
      expect(RedisStore::HStore).to have_received(:set).with(key:, value: 2)
    end
  end

  describe 'if a ticket is destroyed' do
    let(:user) { create(:user) }
    let(:ticket) { build(:ticket, user:) }
    let(:key) { "tickets-#{user.id}" }

    before do
      ticket.save
      allow(RedisStore::HStore).to receive(:get).with(key:).and_return(10)
      allow(RedisStore::HStore).to receive(:set)
    end

    it 'updates cached tickets' do
      ticket.destroy
      expect(RedisStore::HStore).to have_received(:get).with(key:)
      expect(RedisStore::HStore).to have_received(:set).with(key:, value: 9)
    end
  end
end
