require 'rails_helper'

RSpec.describe Labeling::RelabelService, type: :service do
  subject(:service) { described_class.new(from:) }

  let(:from) { Time.zone.now }

  describe '#initialize' do
    it 'sets the "from" attribute' do
      expect(service.from).to eq(from)
    end
  end

  describe '#relabel' do
    let(:ticket_labeling_service) { instance_double(Service::Contributions::TicketLabelingService) }
    let(:fees_labeling_service) { instance_double(Service::Contributions::FeesLabelingService) }

    before do
      allow(Service::Contributions::TicketLabelingService).to receive(:new).and_return(ticket_labeling_service)
      allow(ticket_labeling_service).to receive(:label_donation)
      allow(Service::Contributions::FeesLabelingService).to receive(:new).and_return(fees_labeling_service)
      allow(fees_labeling_service).to receive(:spread_fee_to_payers)
    end

    it 'calls label_donation for Donation records' do
      create(:donation, created_at: from)
      service.relabel

      expect(ticket_labeling_service).to have_received(:label_donation)
    end

    it 'calls spread_fee_to_payers for Contribution records' do
      create(:contribution, :with_payment_in_blockchain, created_at: from)
      service.relabel

      expect(fees_labeling_service).to have_received(:spread_fee_to_payers)
    end
  end
end
