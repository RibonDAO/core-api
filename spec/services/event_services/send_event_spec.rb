require 'rails_helper'

RSpec.describe EventServices::SendEvent, type: :service do
  subject(:service) { described_class.new(user:, event:) }

  describe '#send_event' do
    let(:user) { create(:user, email: 'user100@example.com') }

    let(:event) do
      OpenStruct.new({
                       name: 'purchase',
                       data: {
                         price: 1000,
                         quantity: 1
                       }
                     })
    end

    include_context('when mocking a request') { let(:cassette_name) { 'send_event_customer' } }

    it 'send event track' do
      expect(service.call.code).to eq('200')
    end
  end
end
