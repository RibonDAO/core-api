require 'rails_helper'

RSpec.describe Crm::Customer::Track do
  subject(:service) { described_class.new }

  let(:user) { build(:user, email: "user100@example.com") }
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

  describe '#send_event' do
    it 'send event track' do
      expect(service.send_event(user, event).code).to eq('200')
    end
  end
end
