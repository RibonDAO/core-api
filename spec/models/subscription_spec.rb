# == Schema Information
#
# Table name: subscriptions
#
#  id                   :bigint           not null, primary key
#  cancel_date          :datetime
#  next_payment_attempt :datetime
#  payer_type           :string
#  payment_method       :string
#  platform             :string
#  receiver_type        :string
#  status               :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_id          :string
#  integration_id       :bigint
#  offer_id             :bigint
#  payer_id             :uuid
#  receiver_id          :bigint
#
require 'rails_helper'

RSpec.describe Subscription, type: :model do
  subject(:subscription) { create(:subscription) }

  describe 'validations' do
    it { is_expected.to belong_to(:payer) }
    it { is_expected.to belong_to(:receiver).optional }
    it { is_expected.to belong_to(:offer).optional }
    it { is_expected.to belong_to(:integration) }
  end

  # rubocop:disable RSpec/LetSetup
  describe 'active from club' do
    describe 'when subscription last payment is paid today' do
      let(:offer) { create(:offer, category: :club) }
      let(:club_subscription) { create(:subscription, offer:) }
      let!(:person_payment) do
        create(:person_payment, paid_date: Time.zone.now, subscription: club_subscription, status: :paid)
      end

      it 'returns active subscriptions from club' do
        expect(described_class.active_from_club).to include(club_subscription)
      end
    end

    describe 'when subscription last payment is paid 15 days ago' do
      let(:offer) { create(:offer, category: :club) }
      let(:club_subscription) { create(:subscription, offer:) }
      let!(:person_payment) do
        create(:person_payment, paid_date: 15.days.ago, subscription: club_subscription, status: :paid)
      end

      it 'returns active subscriptions from club' do
        expect(described_class.active_from_club).to include(club_subscription)
      end
    end

    describe 'when subscription last payment is paid more than 1 month ago' do
      let(:offer) { create(:offer, category: :club) }
      let(:club_subscription) { create(:subscription, offer:) }
      let!(:person_payment) do
        create(:person_payment, paid_date: 1.month.ago - 1.day, subscription: club_subscription, status: :paid)
      end

      it 'returns active subscriptions from club' do
        expect(described_class.active_from_club).not_to include(club_subscription)
      end
    end

    describe 'when subscription last payment is refunded' do
      let(:offer) { create(:offer, category: :club) }
      let(:club_subscription) { create(:subscription, offer:, status: :canceled) }
      let!(:person_payment) do
        create(:person_payment, paid_date: Time.zone.now, subscription: club_subscription, status: :refunded)
      end

      it 'returns active subscriptions from club' do
        expect(described_class.active_from_club).to include(club_subscription)
      end
    end
  end
  # rubocop:enable RSpec/LetSetup
end
