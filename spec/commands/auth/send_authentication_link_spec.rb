# frozen_string_literal: true

require 'rails_helper'

describe Auth::SendAuthenticationLink do
  describe '.call' do
    subject(:command) { described_class.call(authenticatable:) }

    let(:authenticatable) { create(:big_donor) }
    let(:email_link_service) { instance_double(Auth::EmailLinkService, find_or_create_auth_link: auth_link) }
    let(:auth_link) { 'https://auth.ribon.io/link' }

    before do
      allow(SendgridWebMailer).to receive(:send_email)
      allow(Auth::EmailLinkService).to receive(:new).and_return(email_link_service)
    end

    it 'sends an email with the authentication link with correct params' do
      command

      expect(SendgridWebMailer).to have_received(:send_email).with(
        receiver: authenticatable.email,
        template_name: 'authentication_email_template_id',
        language: 'en',
        dynamic_template_data: { url: auth_link, first_name: authenticatable.name }
      )
    end
  end
end
