# == Schema Information
#
# Table name: user_donation_stats
#
#  id                 :bigint           not null, primary key
#  last_donated_cause :bigint
#  last_donation_at   :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  user_id            :bigint           not null
#
require 'rails_helper'

RSpec.describe UserDonationStats, type: :model do
  describe '.validations' do
    subject { build(:user_donation_stats) }

    it { is_expected.to belong_to(:user) }
  end

  describe '#next_donation_at' do
    subject(:user_donation_stats) { build(:user_donation_stats, last_donation_at: last_donation_date, user:) }

    let(:user) { build(:user) }
    let(:integration) { build(:integration, ticket_availability_in_minutes: nil) }

    context 'when the last donation is nil' do
      let(:last_donation_date) { nil }

      it 'returns nil' do
        expect(user_donation_stats.next_donation_at(integration)).to be_nil
      end
    end

    context 'when there is a last donation' do
      let(:last_donation_date) { parsed_date('12-01-2021 10:00:00') }

      before do
        create(:donation, created_at: last_donation_date, integration:, user:)
      end

      it 'returns when the next donation is available based on cooldown and last donation' do
        expect(user_donation_stats.next_donation_at(integration)).to eq parsed_date('13-01-2021 00:00:00')
      end
    end
  end

  describe '#can_donate?' do
    let(:integration) { build(:integration, ticket_availability_in_minutes: nil) }

    context 'when the next_donation_at is nil' do
      let(:user_donation_stats) do
        build(:user_donation_stats, last_donation_at: nil)
      end

      it 'returns true' do
        expect(user_donation_stats.can_donate?(integration)).to be_truthy
      end
    end

    context 'when the next_donation_at is higher than now' do
      let(:user_donation_stats) do
        build(:user_donation_stats, last_donation_at: parsed_date('12-01-2021 10:00:00'))
      end

      before do
        mock_now('13-01-2021 8:00:00')
      end

      it 'returns true' do
        expect(user_donation_stats.can_donate?(integration)).to be_truthy
      end
    end

    context 'when the next_donation_at is higher than now due to ticket availability' do
      let(:integration) { build(:integration, ticket_availability_in_minutes: 30) }
      let(:user) { build(:user) }

      let(:user_donation_stats) do
        build(:user_donation_stats, user:)
      end

      before do
        mock_now('13-01-2021 10:40:00')
        create(:donation, created_at: parsed_date('13-01-2021 10:00:00'), integration:, user:)
      end

      it 'returns true' do
        expect(user_donation_stats.can_donate?(integration)).to be_truthy
      end
    end

    context 'when the next_donation_at is lower than now' do
      let(:user) { build(:user) }
      let(:user_donation_stats) do
        build(:user_donation_stats, user:)
      end
      let(:integration) { build(:integration) }

      before do
        mock_now('12-01-2021 14:00:00')
        create(:donation, created_at: parsed_date('12-01-2021 10:00:00'), integration:, user:)
      end

      it 'returns false' do
        expect(user_donation_stats.can_donate?(integration)).to be_falsey
      end
    end

    context 'when the next_donation_at is lower than now due to ticket availability' do
      let(:integration) { build(:integration, ticket_availability_in_minutes: 50) }
      let(:user) { build(:user) }

      let(:user_donation_stats) do
        build(:user_donation_stats, user:)
      end

      before do
        mock_now('13-01-2021 10:40:00')
        create(:donation, created_at: parsed_date('13-01-2021 10:00:00'), integration:, user:)
      end

      it 'returns false' do
        expect(user_donation_stats.can_donate?(integration)).to be_falsey
      end
    end
  end
end
