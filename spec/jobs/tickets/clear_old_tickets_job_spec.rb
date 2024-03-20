require 'rails_helper'

RSpec.describe Tickets::ClearOldTicketsJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now }

    let(:command) { Tickets::ClearOldTickets }

    before do
      allow(command).to receive(:call)
      perform_job
    end

    it 'calls ClearOldTickets' do
      expect(command).to have_received(:call)
    end
  end
end
