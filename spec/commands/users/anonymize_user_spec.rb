# frozen_string_literal: true

require 'rails_helper'

describe Users::AnonymizeUser do
  describe '.call' do
    subject(:command) { described_class.call(user) }

    let(:user) { create(:user) }
    let(:random_string) { 'random_string' }

    before do
      allow(SecureRandom).to receive(:hex).and_return(random_string)
    end
    
    it 'updates the user email' do
      command
      expect(user.reload.email).to eq("deleted_user+random_string@ribon.io")
    end
  end
end
