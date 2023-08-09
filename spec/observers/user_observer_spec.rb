require 'rails_helper'

RSpec.describe UserObserver, type: :observer do
  describe 'if a user is created' do
    let(:user) { build(:user) }

    before do
      allow(Users::HandlePostUserJob).to receive(:perform_later).with(user:)
    end

    it 'calls the handle post user job' do
      user.save
      expect(Users::HandlePostUserJob).to have_received(:perform_later).with(user:)
    end
  end
end
