require 'rails_helper'

RSpec.describe Service::Contributions::StatisticsService, type: :service do
  subject(:service) { described_class.new(contribution:) }

  let(:cause) { create(:cause) }
  let(:person_payment) { create(:person_payment, usd_value_cents: 1_000) }
  let(:contribution) { create(:contribution, :with_contribution_balance, receiver: cause, person_payment:) }

  before do
    create(:ribon_config, contribution_fee_percentage: 20, minimum_contribution_chargeable_fee_cents: 10)
  end

  describe '#formatted_statistics' do
    it 'returns the necessary keys' do
      expect(service.formatted_statistics.keys)
        .to match_array(%i[initial_amount used_amount
                           remaining_amount total_tickets avg_donations_per_person
                           boost_amount total_increase_percentage total_amount_to_cause ribon_fee])
    end
  end
end
