# spec/commands/users/verify_club_membership_spec.rb
require 'rails_helper'

describe Users::VerifyClubMembership do
  describe '.call' do
    subject(:command) { described_class.call(user:) }

    let(:user) { create(:user) }
    let(:customer) { create(:customer, user:) }
    let(:offer) { create(:offer, category: :club) }
    let(:subscription) { create(:subscription, payer: customer, offer:, status: :active) }

    context 'when user is a club member' do
      before do
        create(:person_payment, payer: customer, subscription:)
      end

      it 'returns true' do
        expect(command.result).to be_truthy
      end
    end

    context 'when user is not a club member' do
      let(:subscription) { create(:subscription, payer: customer, offer:, status: :inactive) }

      before do
        create(:person_payment, payer: customer, subscription:)
      end

      it 'returns false' do
        expect(command.result).to be_falsey
      end
    end
  end
end
