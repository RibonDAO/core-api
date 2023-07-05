require 'rails_helper'

RSpec.describe Contributions::HandleUpdateContributionBalanceJob, type: :job do
  describe '#perform' do
    subject(:job) { described_class }

    let(:contribution_balance) { create(:contribution_balance) }
    let(:big_donor) { create(:big_donor) }
    let(:job_instance) { described_class.new }

    before do
      allow(Mailers::Contributions::SendPatronContributions100PercentEmailJob).to receive(:perform_later)
      allow(Mailers::Contributions::SendPatronContributions95PercentEmailJob).to receive(:perform_later)
      allow(Mailers::Contributions::SendPatronContributions75PercentEmailJob).to receive(:perform_later)
      allow(Mailers::Contributions::SendPatronContributions50PercentEmailJob).to receive(:perform_later)
      allow(Mailers::Contributions::SendPatronContributions25PercentEmailJob).to receive(:perform_later)
      allow(Mailers::Contributions::SendPatronContributions10PercentEmailJob).to receive(:perform_later)
      allow(Mailers::Contributions::SendPatronContributions5PercentEmailJob).to receive(:perform_later)
      allow(EmailLog).to receive(:email_already_sent?).and_return(false)
    end

    # rubocop:disable RSpec/ExampleLength
    it 'sends the appropriate email job when contribution balance is updated' do
      percentage = 100
      allow(job_instance).to receive(:find_closest_email_percentage).and_return(percentage)

      job_instance.perform(contribution_balance:, big_donor:)

      expect(Mailers::Contributions::SendPatronContributions100PercentEmailJob).to have_received(:perform_later)
                                                                               .with(big_donor:)
      expect(Mailers::Contributions::SendPatronContributions95PercentEmailJob).not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions75PercentEmailJob).not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions50PercentEmailJob).not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions25PercentEmailJob).not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions10PercentEmailJob).not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions5PercentEmailJob).not_to have_received(:perform_later)
    end
    # rubocop:enable RSpec/ExampleLength

    it 'does not send the email if it has already been sent' do
      allow(EmailLog).to receive(:email_already_sent?).and_return(true)

      job_instance.perform(contribution_balance:, big_donor:)

      expect(Mailers::Contributions::SendPatronContributions100PercentEmailJob)
        .not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions95PercentEmailJob).not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions75PercentEmailJob).not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions50PercentEmailJob).not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions25PercentEmailJob).not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions10PercentEmailJob).not_to have_received(:perform_later)
      expect(Mailers::Contributions::SendPatronContributions5PercentEmailJob).not_to have_received(:perform_later)
    end
  end
end
