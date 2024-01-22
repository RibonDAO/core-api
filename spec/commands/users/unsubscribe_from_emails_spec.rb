# frozen_string_literal: true

require 'rails_helper'

describe Users::UnsubscribeFromEmails do
  describe '.call' do
    subject(:command) { described_class.call(email: user.email) }

    let(:user) { create(:user, user_config:) }
    let(:user_config) { create(:user_config, allowed_email_marketing: true) }

    it 'updates the user config' do
      command
      expect(user.reload.user_config.allowed_email_marketing).to be_falsey
    end
  end
end
