# frozen_string_literal: true

require 'rails_helper'

describe Auth::Accounts::SendOtpEmail do
  let(:integration) { create(:integration) }
  let(:event_service_double) { instance_double(EventServices::SendEvent) }
  let(:authenticatable) { create(:account) }
  let(:otp_code_service) { instance_double(Auth::OtpCodeService, create_otp_code: otp_code) }
  let(:otp_code) { '012345' }

  before do
    allow(Auth::OtpCodeService).to receive(:new).and_return(otp_code_service)
    allow(EventServices::SendEvent).to receive(:new).and_return(event_service_double)
    allow(event_service_double).to receive(:call)
  end

  context 'when request is using email' do
    let(:command) do
      described_class.call(email: authenticatable.email,
                           id: nil,
                           current_email: authenticatable.email)
    end

    let(:event) do
      OpenStruct.new({
                       name: 'authorize_email_with_otp',
                       data: {
                         email: authenticatable.email,
                         code: otp_code
                       }
                     })
    end

    it 'calls EventServices::SendEvent with correct arguments' do
      command
      expect(EventServices::SendEvent).to have_received(:new).with({ user: authenticatable.user,
                                                                     event: })
    end

    it 'calls EventServices::SendEvent call' do
      command
      expect(event_service_double).to have_received(:call)
    end

    it 'creates a profile' do
      expect { command }.to change(UserProfile, :count).by(1)
    end

    context 'when email and current email dont match' do
      let(:command) do
        described_class.call(email: authenticatable.email, id: nil, current_email: 'test1@email.com')
      end

      it 'returns a error message' do
        expect(command.errors[:message]).to eq(['Email does not match'])
      end
    end
  end

  context 'when request is using account id' do
    let(:command) do
      described_class.call(email: nil,
                           id: authenticatable.id,
                           current_email: authenticatable.email)
    end

    let(:event) do
      OpenStruct.new({
                       name: 'authorize_email_with_otp',
                       data: {
                         email: authenticatable.email,
                         code: otp_code
                       }
                     })
    end

    it 'calls EventServices::SendEvent with correct arguments' do
      command
      expect(EventServices::SendEvent).to have_received(:new).with({ user: authenticatable.user,
                                                                     event: })
    end

    it 'calls EventServices::SendEvent call' do
      command
      expect(event_service_double).to have_received(:call)
    end

    it 'creates a profile' do
      expect { command }.to change(UserProfile, :count).by(1)
    end
  end

  context 'when email and id are not present' do
    let(:command) do
      described_class.call(email: nil, id: nil, current_email: nil)
    end

    it 'does not call EventServices::SendEvent call' do
      command
      expect(event_service_double).not_to have_received(:call)
    end

    it 'returns a error message' do
      expect(command.errors[:message]).to eq(['Email or id must be present'])
    end
  end
end
