require 'rails_helper'

RSpec.describe Tracking::AddUtmJob, type: :job do
  describe '#perform' do
    subject(:perform_job) { described_class.perform_now(utm_params:, trackable:) }

    let(:utm_params) do
      OpenStruct.new({ utm_medium: '',
                       utm_source: '',
                       utm_campaign: '' })
    end
    let(:trackable) { create(:ticket) }

    before do
      allow(Tracking::AddUtm).to receive(:call)
      perform_job
    end

    it 'calls AddUtmJob' do
      expect(Tracking::AddUtm).to have_received(:call).with(utm_params:, trackable:)
    end
  end
end
