require 'rails_helper'

RSpec.describe ContributionObserver, type: :observer do
  describe 'if a contribution is created' do
    before do
      allow(Events::Contributions::SendContributionEventJob).to receive(:perform_later).with(contribution:)
    end

    context 'when the payer is a customer' do
      let(:customer) { create(:customer) }
      let(:person_payment) { create(:person_payment, payer: customer) }
      let(:contribution) { build(:contribution, person_payment: person_payment) }

      it 'calls the send contribution event job' do
        contribution.save
        expect(Events::Contributions::SendContributionEventJob).to have_received(:perform_later).with(contribution:)
      end
    end

    context 'when the payer is not a customer' do
      let(:big_donor) { create(:big_donor) }
      let(:person_payment) { create(:person_payment, payer: big_donor) }
      let(:contribution) { build(:contribution, person_payment: person_payment) }

      it 'does not call the send contribution event job' do
        contribution.save
        expect(Events::Contributions::SendContributionEventJob).not_to have_received(:perform_later).with(contribution:)
      end
    end
  end
end
