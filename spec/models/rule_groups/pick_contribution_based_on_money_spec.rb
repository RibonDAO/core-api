require 'rails_helper'

RSpec.describe PickContributionBasedOnMoney, type: :model do
  include ActiveStorage::Blob::Analyzable

  subject(:request) { described_class.new(donation) }

  let(:donation) { create(:donation) }
  let(:big_donor) { create(:big_donor) }
  let(:customer) { create(:customer) }
  let(:big_donor_person_payment) { create(:person_payment, payer: big_donor, usd_value_cents: 500) }
  let(:customer_person_payment) { create(:person_payment, payer: customer, usd_value_cents: 500) }
  let(:contributions_from_big_donors) do
    create_list(:contribution, 2, :with_contribution_balance, person_payment: big_donor_person_payment)
  end
  let(:contributions_from_promoters) do
    create_list(:contribution, 2, :with_contribution_balance, person_payment: customer_person_payment)
  end

  before do
    create(:ribon_config)
    contributions_from_big_donors
    contributions_from_promoters
  end

  describe '#call' do
    let(:chosen_contributions) { Contribution.all }

    it 'returns a chosen contribution' do
      result = request.call({ chosen: chosen_contributions, found: false })

      expect(chosen_contributions).to include(result[:chosen])
    end

    it 'returns a result with found attribute as true' do
      result = request.call({ chosen: chosen_contributions, found: false })

      expect(result[:found]).to be true
    end
  end

  describe '#calculate_contributions_probability_based_on_money' do
    let(:contributions_group) do
      [
        OpenStruct.new(id: 1, usd_value_cents: 2000),
        OpenStruct.new(id: 2, usd_value_cents: 3000),
        OpenStruct.new(id: 3, usd_value_cents: 5000)
      ]
    end

    it 'returns a hash with probabilities for the contributions based on money' do
      probabilities_hash = request.send(:calculate_contributions_probability_based_on_money, contributions_group)

      expect(probabilities_hash).to eq(
        1 => 0.2,
        2 => 0.3,
        3 => 0.5
      )
    end
  end

  describe '#select_contribution_id' do
    let(:contributions_group) do
      [
        OpenStruct.new(id: 1, usd_value_cents: 2000),
        OpenStruct.new(id: 2, usd_value_cents: 3000),
        OpenStruct.new(id: 3, usd_value_cents: 5000)
      ]
    end

    it 'returns a contribution ID based on the probabilities hash' do
      probabilities_hash = {
        1 => 0.2,
        2 => 0.4,
        3 => 0.6
      }
      random_number = 0.45

      allow(Random).to receive(:rand).and_return(random_number)

      contribution_id = request.send(:select_contribution_id, probabilities_hash)

      expect(contribution_id).to eq(2)
    end
  end
end
