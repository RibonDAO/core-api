# frozen_string_literal: true

require 'rails_helper'

describe BigDonors::UpdateBigDonor do
  describe '.call' do
    subject(:command) { described_class.call(big_donor_params) }

    context 'when updates with the right params' do
      let(:big_donor) { create(:big_donor) }
      let(:big_donor_params) do
        {
          id: big_donor.id,
          name: 'New big donor',
          email: 'mynewemail@gmail.com'
        }
      end

      context 'when updates and has success' do
        it 'updates a big_donor' do
          command

          expect(BigDonor.count).to eq(1)
          expect(BigDonor.first.name).to eq('New big donor')
        end
      end
    end
  end
end
