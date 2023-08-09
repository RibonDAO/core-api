require 'rails_helper'

RSpec.describe ChooseBetweenBigDonorsAndPromoters, type: :model do
  include ActiveStorage::Blob::Analyzable

  subject { described_class.new(donation) }

  let(:big_donor) { create(:big_donor) }
  let(:customer) { create(:customer) }
  let(:big_donor_person_payment) { create(:person_payment, payer: big_donor, usd_value_cents: 100) }
  let(:customer_person_payment) { create(:person_payment, payer: customer, usd_value_cents: 100) }
  let(:contributions_from_big_donors) do
    create_list(:contribution, 2, :with_contribution_balance, person_payment: big_donor_person_payment)
  end
  let(:contributions_from_promoters) do
    create_list(:contribution, 2, :with_contribution_balance, person_payment: customer_person_payment)
  end
  let(:donation) { create(:donation) }

  before do
    create(:ribon_config)
    contributions_from_big_donors
    contributions_from_promoters
  end

  describe '#call' do
    let(:chosen_contributions) { Contribution.from_big_donors }
    let(:response) { subject.call({ chosen: chosen_contributions, found: false }) }

    context 'when there are no promoters contributions' do
      it 'returns big donors response' do
        expect(response[:chosen].pluck(:id)).to eq(chosen_contributions.pluck(:id))
      end
    end

    context 'when there are no big donors contributions' do
      let(:chosen_contributions) { Contribution.from_unique_donors }
      let(:response) { subject.call({ chosen: chosen_contributions, found: false }) }

      it 'returns promoters response' do
        expect(response[:chosen].pluck(:id)).to eq(chosen_contributions.pluck(:id))
      end
    end

    context 'when there are both big donors and promoters contributions' do
      let(:chosen_contributions) { Contribution.all }
      let(:response) { subject.call({ chosen: chosen_contributions, found: false }) }

      context 'when the random number goes to a promoter range' do
        it 'chooses a promoter contributions array' do
          allow(Random).to receive(:rand).and_return(0.3)

          expect(response[:chosen].pluck(:id)).to eq(contributions_from_promoters.pluck(:id))
        end
      end

      context 'when the random number goes to a big donor range' do
        it 'chooses a promoter big donors array' do
          allow(Random).to receive(:rand).and_return(0.8)

          expect(response[:chosen].pluck(:id)).to eq(contributions_from_big_donors.pluck(:id))
        end
      end
    end
  end
end
