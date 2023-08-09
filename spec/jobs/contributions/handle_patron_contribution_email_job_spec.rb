require 'rails_helper'

RSpec.describe Contributions::HandlePatronContributionEmailJob, type: :job do
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
                                                                               .with(big_donor:,
                                                                                     statistics: anything)
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

    it 'sends the appropriate email job for different percentages' do
      [100, 95, 75, 50, 25, 10, 5].each do |percentage|
        allow(job_instance).to receive(:find_closest_email_percentage).and_return(percentage)

        job_instance.perform(contribution_balance:, big_donor:)
        mailer_class = "Mailers::Contributions::SendPatronContributions#{percentage}PercentEmailJob".constantize

        expect(mailer_class).to have_received(:perform_later).with(big_donor:,
                                                                   statistics: anything)
      end
    end
  end
end
