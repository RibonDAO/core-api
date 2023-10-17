# == Schema Information
#
# Table name: big_donors
#
#  id         :uuid             not null, primary key
#  email      :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe BigDonor, type: :model do
  describe '.validations' do
    subject { build(:big_donor) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity }
    it { is_expected.to have_many(:person_payments) }
  end

  describe '#dashboard_link' do
    subject(:big_donor) { create(:big_donor) }

    let(:email_link_mock) { instance_double(Auth::EmailLinkService, find_or_create_auth_link: 'link') }

    it 'returns the email link service link' do
      allow(Auth::EmailLinkService).to receive(:new).with(authenticatable: big_donor).and_return(email_link_mock)

      expect(big_donor.dashboard_link).to eq 'link'
    end
  end
end
