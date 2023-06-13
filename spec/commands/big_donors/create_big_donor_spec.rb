# frozen_string_literal: true

require 'rails_helper'

describe BigDonors::CreateBigDonor do
  describe '.call' do
    subject(:command) { described_class.call(big_donor_params) }

    context 'when creates with the right params' do
      let(:big_donor_params) do
        {
          name: 'New big donor',
          email: 'new_big_donor@gmail.com'
        }
      end

      context 'when creates and has success' do
        it 'creates a new big_donor with the right params' do
          command
          expect(BigDonor.count).to eq(1)
          expect(command.result.name).to eq(big_donor_params[:name])
          expect(command.result.email).to eq(big_donor_params[:email])
        end
      end
    end
  end
end
