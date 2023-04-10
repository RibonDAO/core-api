require 'rails_helper'

RSpec.describe ChooseContributionsCause, type: :model do
  subject(:rule) { described_class.new(donation) }

  let(:donation) { create(:donation, non_profit:) }
  let(:non_profit) { create(:non_profit, cause:) }
  let(:cause) { create(:cause) }

  let(:contributions_from_donation_cause) { create_list(:contribution, 2, receiver: cause) }
  let(:contributions_from_other_cause) { create_list(:contribution, 2, receiver: create(:cause)) }

  before do
    contributions_from_donation_cause
    contributions_from_other_cause
  end

  describe '#call' do
    it 'returns the contributions filtered by the donation cause' do
      input = {
        chosen: Contribution.all,
        found: false
      }
      response = rule.call(input)

      expect(response[:chosen].pluck(:id)).to match_array(contributions_from_donation_cause.pluck(:id))
    end
  end
end
