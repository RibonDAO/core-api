# frozen_string_literal: true

require 'rails_helper'

describe Contributions::Labeling::DetermineChosenContribution do
  include ActiveStorage::Blob::Analyzable

  describe '#call' do
    subject(:command) { described_class.new(donation:) }

    let(:donation_value) { 100 }
    let(:donation) { create(:donation) }
    let(:rules_set) { instance_double }

    context 'when there are no valid base contributions' do
      before do
        person_payment = create(:person_payment, status: :refunded)
        contribution = create(:contribution, person_payment:)
        create(:contribution_balance, contribution:, tickets_balance_cents: 10_000)
      end

      it 'does not apply any rules and return nil' do
        expect(command.call.result).to be_nil
      end
    end

    context 'when there are base contributions' do
      let(:rules) do
        [ChooseBetweenBigDonorsAndPromoters, ChooseContributionsCause,
         FetchContributionsWithLowRemainingAmount, PickContributionBasedOnMoney]
      end

      let(:chosen_contribution) { build(:contribution, :with_contribution_balance) }
      let(:rule_instance1) do
        instance_double(ChooseBetweenBigDonorsAndPromoters, call: { chosen: [], found: false })
      end
      let(:rule_instance2) { instance_double(ChooseContributionsCause, call: { chosen: [], found: false }) }
      let(:rule_instance3) do
        instance_double(FetchContributionsWithLowRemainingAmount, call: { chosen: [], found: false })
      end
      let(:rule_instance4) do
        instance_double(PickContributionBasedOnMoney, call: { chosen: chosen_contribution, found: true })
      end

      before do
        allow(RuleGroup).to receive(:rules_set).and_return(rules)
        allow(ChooseBetweenBigDonorsAndPromoters).to receive(:new).and_return(rule_instance1)
        allow(ChooseContributionsCause).to receive(:new).and_return(rule_instance2)
        allow(FetchContributionsWithLowRemainingAmount).to receive(:new).and_return(rule_instance3)
        allow(PickContributionBasedOnMoney).to receive(:new).and_return(rule_instance4)
      end

      it 'call all the rules' do
        command.call

        expect(rule_instance1).to have_received(:call).with({ chosen: [], found: false })
        expect(rule_instance2).to have_received(:call).with({ chosen: [], found: false })
        expect(rule_instance3).to have_received(:call).with({ chosen: [], found: false })
        expect(rule_instance4).to have_received(:call).with({ chosen: [], found: false })
      end

      it 'applies rules until a chosen contribution is found' do
        expect(command.call.result).to eq(chosen_contribution)
      end
    end
  end
end
