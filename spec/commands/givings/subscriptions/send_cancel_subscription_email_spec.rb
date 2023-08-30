require 'rails_helper'

describe Givings::Subscriptions::SendCancelSubscriptionEmail do
  describe '.call' do
    include ActiveStorage::Blob::Analyzable
    subject(:command) { described_class.call(args) }

    let(:user) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let(:subscription) { create(:subscription, payer: customer) }
    let!(:person_payment) { create(:person_payment, subscription:, payer: customer) }
    let(:args) { { subscription: } }
    let(:jwt) { 'jwt.webtoken' }
    let(:url) { "https://dapp.ribon.io/monthly-contribution-canceled?token=#{jwt}" }

    let(:event_service_double) { instance_double(EventServices::SendEvent) }
    let(:event) do
      OpenStruct.new({
                       name: 'cancel_subscription',
                       data: {
                         receiver_name: subscription.receiver.name,
                         subscription_id: subscription.id,
                         user: subscription.payer.user,
                         amount: person_payment.formatted_amount,
                         url:,
                         status: subscription.status
                       }
                     })
    end

    context 'when it is successful' do
      before do
        allow(EventServices::SendEvent).to receive(:new).and_return(event_service_double)
        allow(event_service_double).to receive(:call)
        allow(Jwt::Encoder).to receive(:encode).and_return(jwt)
      end

      it 'calls EventServices::SendEvent with correct arguments' do
        command
        expect(EventServices::SendEvent).to have_received(:new).with({ user: subscription.payer.user,
                                                                       event: })
      end

      it 'calls EventServices::SendEvent call' do
        command
        expect(event_service_double).to have_received(:call)
      end
    end

    context 'when it is not successful' do
      before do
        allow(EventServices::SendEvent).to receive(:new).and_raise(StandardError, 'error message')
        allow(Reporter).to receive(:log)
      end

      it 'adds error to errors' do
        expect(command.errors).to include(message: ['error message'])
      end

      it 'logs error' do
        command
        expect(Reporter).to have_received(:log).with(error: StandardError, extra: { message: 'error message' })
      end
    end
  end
end
