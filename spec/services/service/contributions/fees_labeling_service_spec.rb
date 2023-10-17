require 'rails_helper'

RSpec.describe Service::Contributions::FeesLabelingService, type: :service do
  before do
    create(:ribon_config, contribution_fee_percentage: 20, minimum_contribution_chargeable_fee_cents: 10)
  end

  describe '#spread_fee_to_payers' do
    let!(:person_payment) do
      create(:person_payment, :with_payment_in_blockchain,
             usd_value_cents: 1000, status: :paid, created_at: 1.day.from_now)
    end
    let!(:contribution) { create(:contribution, person_payment:) }
    let!(:contribution_balance1) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment,
                                                                        :with_payment_in_blockchain,
                                                                        status: :paid)),
             fees_balance_cents: 50)
    end
    let!(:contribution_balance2) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment,
                                                                        :with_payment_in_blockchain,
                                                                        status: :paid)),
             fees_balance_cents: 30)
    end
    let!(:contribution_balance3) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment,
                                                                        :with_payment_in_blockchain,
                                                                        status: :paid)),
             fees_balance_cents: 20)
    end

    it 'creates a fee for each feeable contribution balance' do
      fee_service = described_class.new(contribution:)

      expect { fee_service.spread_fee_to_payers }.to change(ContributionFee, :count).by(3)
    end

    it 'generates all the contribution fees' do
      fee_service = described_class.new(contribution:)

      fee_service.spread_fee_to_payers

      expect(ContributionFee.sum(:fee_cents)).to eq(100)
    end

    it 'updates the fees balance of each affected contribution balance' do
      fee_service = described_class.new(contribution:)

      fee_service.spread_fee_to_payers

      expect(contribution_balance1.reload.fees_balance_cents).to eq(0)
      expect(contribution_balance2.reload.fees_balance_cents).to eq(0)
      expect(contribution_balance3.reload.fees_balance_cents).to eq(0)
    end
  end

  context 'when there is a minimum fee' do
    let(:person_payment) do
      create(:person_payment, :with_payment_in_blockchain, created_at: 1.day.from_now,
                                                           usd_value_cents: 1000, status: :paid)
    end
    let(:contribution) { create(:contribution, person_payment:) }

    # 4.545
    let!(:contribution_balance1) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment,
                                                                        :with_payment_in_blockchain,
                                                                        status: :paid)),
             fees_balance_cents: 5)
    end
    # 13.636
    let!(:contribution_balance2) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment,
                                                                        :with_payment_in_blockchain,
                                                                        status: :paid)),
             fees_balance_cents: 15)
    end
    # 27.272
    let!(:contribution_balance3) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment,
                                                                        :with_payment_in_blockchain,
                                                                        status: :paid)),
             fees_balance_cents: 30)
    end
    # 54.545
    let!(:contribution_balance4) do
      create(:contribution_balance,
             contribution: create(:contribution, receiver: contribution.receiver,
                                                 person_payment: create(:person_payment,
                                                                        :with_payment_in_blockchain,
                                                                        status: :paid)),
             fees_balance_cents: 60)
    end

    it 'stops spreading the fee when a contribution balance reaches the minimum fee' do
      fee_service = described_class.new(contribution:)

      fee_service.spread_fee_to_payers

      expect(ContributionFee.sum(:fee_cents)).to eq(100)
      expect(contribution_balance1.reload.fees_balance_cents).to eq(0)
      expect(contribution_balance2.reload.fees_balance_cents).to eq(1)
      expect(contribution_balance3.reload.fees_balance_cents).to eq(2)
      expect(contribution_balance4.reload.fees_balance_cents).to eq(7)
    end
  end

  context 'when the fees were already spread' do
    it "doesn't spread the fees again" do
      contribution = create(:contribution)
      create(:contribution_fee, contribution:)

      fee_service = described_class.new(contribution:)

      expect { fee_service.spread_fee_to_payers }.not_to change(ContributionFee, :count)
    end
  end

  context 'when there is more than one cause' do
    let(:health) { create(:cause) }
    let(:water) { create(:cause) }
    let!(:health_contribution1) { create(:contribution, :feeable, receiver: health) }
    let!(:health_contribution2) { create(:contribution, :feeable, receiver: health) }
    let!(:health_contribution3) { create(:contribution, :feeable, receiver: health) }
    let!(:water_contribution1) { create(:contribution, :feeable, receiver: water) }
    let!(:water_contribution2) { create(:contribution, :feeable, receiver: water) }
    let!(:water_contribution3) { create(:contribution, :feeable, receiver: water) }

    context 'when the contribution dont cut out all fee balances avaiable' do
      let(:new_contribution) do
        create(:contribution, :with_payment_in_blockchain,
               receiver: health, generated_fee_cents: 30, created_at: 1.day.from_now)
      end

      it "doesn't change fee balance of different causes" do
        fee_service = described_class.new(contribution: new_contribution)

        expect { fee_service.spread_fee_to_payers }
          .to change {
            water_contribution1.contribution_balance.reload.fees_balance_cents
          }.by(0)
          .and change { water_contribution2.contribution_balance.reload.fees_balance_cents }
          .by(0)
          .and change {
                 water_contribution3.contribution_balance.reload.fees_balance_cents
               }.by(0)
      end

      it "doesn't change ticket balance of different causes" do
        fee_service = described_class.new(contribution: new_contribution)

        expect { fee_service.spread_fee_to_payers }
          .to change {
            water_contribution1.contribution_balance.reload.tickets_balance_cents
          }.by(0)
          .and change { water_contribution2.contribution_balance.reload.tickets_balance_cents }
          .by(0)
          .and change {
                 water_contribution3.contribution_balance.reload.tickets_balance_cents
               }.by(0)
      end

      it 'change the fee balance cents proportionaly' do
        fee_service = described_class.new(contribution: new_contribution)

        expect { fee_service.spread_fee_to_payers }
          .to change {
            health_contribution1.contribution_balance.reload.fees_balance_cents
          }.by(-10)
          .and change { health_contribution2.contribution_balance.reload.fees_balance_cents }.by(-10)
          .and change { health_contribution3.contribution_balance.reload.fees_balance_cents }.by(-10)
      end

      it 'does not change the ticket balance cents' do
        fee_service = described_class.new(contribution: new_contribution)

        expect { fee_service.spread_fee_to_payers }
          .to change {
            health_contribution1.contribution_balance.reload.tickets_balance_cents
          }.by(0)
          .and change { health_contribution2.contribution_balance.reload.tickets_balance_cents }.by(0)
          .and change { health_contribution3.contribution_balance.reload.tickets_balance_cents }.by(0)
      end
    end

    context 'when the contribution cut out all cause balance avaiable' do
      let(:new_contribution) do
        create(:contribution, :with_payment_in_blockchain, created_at: 1.day.from_now,
                                                           receiver: health, generated_fee_cents: 1000)
      end

      it "doesn't spread the fees to different causes" do
        fee_service = described_class.new(contribution: new_contribution)

        expect { fee_service.spread_fee_to_payers }
          .to change {
            water_contribution1.contribution_balance.reload.fees_balance_cents
          }.by(0)
          .and change { water_contribution2.contribution_balance.reload.fees_balance_cents }
          .by(0)
          .and change {
                 water_contribution3.contribution_balance.reload.fees_balance_cents
               }.by(0)
      end

      it "doesn't change ticket balance of different causes" do
        fee_service = described_class.new(contribution: new_contribution)

        expect { fee_service.spread_fee_to_payers }
          .to change {
            water_contribution1.contribution_balance.reload.tickets_balance_cents
          }.by(0)
          .and change { water_contribution2.contribution_balance.reload.tickets_balance_cents }
          .by(0)
          .and change {
                 water_contribution3.contribution_balance.reload.tickets_balance_cents
               }.by(0)
      end

      it "cut out all contribution's fee balance" do
        fee_service = described_class.new(contribution: new_contribution)

        expect { fee_service.spread_fee_to_payers }
          .to change {
            health_contribution1.contribution_balance.reload.fees_balance_cents
          }.to(0)
          .and change { health_contribution2.contribution_balance.reload.fees_balance_cents }.to(0)
          .and change { health_contribution3.contribution_balance.reload.fees_balance_cents }.to(0)
      end

      it "cut out all contribution's tickets balance" do
        fee_service = described_class.new(contribution: new_contribution)

        expect { fee_service.spread_fee_to_payers }
          .to change {
            health_contribution1.contribution_balance.reload.tickets_balance_cents
          }.to(0)
          .and change { health_contribution2.contribution_balance.reload.tickets_balance_cents }.to(0)
          .and change { health_contribution3.contribution_balance.reload.tickets_balance_cents }.to(0)
      end
    end

    context 'when the contribution cut out all cause fee avaiable and some of tickets' do
      let(:new_contribution) do
        create(:contribution, :with_payment_in_blockchain, created_at: 1.day.from_now,
                                                           receiver: health, generated_fee_cents: 330)
      end

      it "cut out all contribution's fee balance" do
        fee_service = described_class.new(contribution: new_contribution)

        expect { fee_service.spread_fee_to_payers }
          .to change {
            health_contribution1.contribution_balance.reload.fees_balance_cents
          }.to(0)
          .and change { health_contribution2.contribution_balance.reload.fees_balance_cents }.to(0)
          .and change { health_contribution3.contribution_balance.reload.fees_balance_cents }.to(0)
      end

      it "change proportionally contribution's tickets balance" do
        fee_service = described_class.new(contribution: new_contribution)

        expect { fee_service.spread_fee_to_payers }
          .to change {
            health_contribution1.contribution_balance.reload.tickets_balance_cents
          }.by(-10)
          .and change { health_contribution2.contribution_balance.reload.tickets_balance_cents }.by(-10)
          .and change { health_contribution3.contribution_balance.reload.tickets_balance_cents }.by(-10)
      end
    end
  end

  context 'when contributions have different fee balances' do
    let(:health) { create(:cause) }
    let(:water) { create(:cause) }
    let!(:health_contribution1) do
      create(:contribution,
             person_payment: create(:person_payment,
                                    :with_payment_in_blockchain,
                                    status: :paid), receiver: health,
             contribution_balance: create(:contribution_balance, fees_balance_cents: 50))
    end
    let!(:health_contribution2) do
      create(:contribution,
             person_payment: create(:person_payment,
                                    :with_payment_in_blockchain,
                                    status: :paid), receiver: health,
             contribution_balance: create(:contribution_balance, fees_balance_cents: 150))
    end
    let!(:health_contribution3) do
      create(:contribution,
             person_payment: create(:person_payment,
                                    :with_payment_in_blockchain,
                                    status: :paid), receiver: health,
             contribution_balance: create(:contribution_balance, fees_balance_cents: 250))
    end
    let(:water_contribution1) do
      create(:contribution,
             person_payment: create(:person_payment,
                                    :with_payment_in_blockchain,
                                    status: :paid), receiver: water)
    end
    let(:water_contribution2) do
      create(:contribution,
             person_payment: create(:person_payment,
                                    :with_payment_in_blockchain,
                                    status: :paid), receiver: water)
    end
    let(:water_contribution3) do
      create(:contribution,
             person_payment: create(:person_payment,
                                    :with_payment_in_blockchain,
                                    status: :paid), receiver: water)
    end

    let(:new_contribution) do
      create(:contribution, :with_payment_in_blockchain, created_at: 1.day.from_now,
                                                         receiver: health, generated_fee_cents: 500)
    end

    it "cut out all contribution's fee balance" do
      fee_service = described_class.new(contribution: new_contribution)

      expect { fee_service.spread_fee_to_payers }
        .to change {
          health_contribution1.contribution_balance.reload.fees_balance_cents
        }.to(0)
        .and change { health_contribution2.contribution_balance.reload.fees_balance_cents }.to(0)
        .and change { health_contribution3.contribution_balance.reload.fees_balance_cents }.to(0)
    end
  end
end
