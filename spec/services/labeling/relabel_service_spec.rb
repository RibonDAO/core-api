require 'rails_helper'

RSpec.describe Labeling::RelabelService, type: :service do
  subject(:service) { described_class.new(from:) }

  let(:from) { 1.year.ago }

  describe '#initialize' do
    it 'sets the "from" attribute' do
      expect(service.from).to eq(from)
    end
  end

  describe '#ordered_records' do
    let!(:donation1) { create(:donation, created_at: 10.days.ago) }
    let!(:donation2) { create(:donation, created_at: 5.days.ago) }
    let!(:donation3) { create(:donation, created_at: 1.day.ago) }
    let!(:contribution1) { create(:contribution) }
    let!(:contribution2) { create(:contribution) }

    before do
      create(:person_blockchain_transaction, treasure_entry_status: :success, succeeded_at: 7.days.ago,
                                             person_payment: contribution1.person_payment)
      create(:person_blockchain_transaction, treasure_entry_status: :success, succeeded_at: 3.days.ago,
                                             person_payment: contribution2.person_payment)
    end

    it 'orders all records according to donation created_at and contribution succeeded_at' do
      expect(service.ordered_records).to eq([donation1, contribution1, donation2, contribution2, donation3])
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
