# spec/commands/users/verify_club_membership_spec.rb
require 'rails_helper'

describe Users::VerifyClubMembership do
  describe '.call' do
    subject(:command) { described_class.call(user:) }

    let(:user) { create(:user) }

    context 'when user is a club member' do
      before do
        create(:customer, user:)
        create(:subscription, payer: user.customers.first, status: :active, offer: create(:offer, category: :club))
      end

      it 'returns true' do
        expect(command.result).to be_truthy
      end
    end

    context 'when user is not a club member' do
      before do
        create(:customer, user:)
        create(:subscription, payer: user.customers.first, status: :active, offer: create(:offer))
      end

      it 'returns false' do
        expect(command.result).to be_falsey
      end
    end
  end
end
