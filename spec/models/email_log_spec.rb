# == Schema Information
#
# Table name: email_logs
#
#  id                  :bigint           not null, primary key
#  email_template_name :string
#  email_type          :integer
#  receiver_type       :string           not null
#  status              :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  receiver_id         :string           not null
#
require 'rails_helper'

RSpec.describe EmailLog, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:receiver) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:email_type).with_values(default: 0, patron_contribution: 1) }
    it { is_expected.to define_enum_for(:status).with_values(enqueued: 0, sent: 1) }
  end

  describe '.email_already_sent?' do
    let(:receiver) { create(:big_donor) }
    let(:email_template_name) { 'template_name' }

    context 'when email log exists for the receiver and template name' do
      before do
        create(:email_log, receiver:, email_template_name:)
      end

      it 'returns true' do
        expect(described_class.email_already_sent?(receiver:, email_template_name:)).to be true
      end
    end

    context 'when email log does not exist for the receiver and template name' do
      it 'returns false' do
        expect(described_class.email_already_sent?(receiver:, email_template_name:)).to be false
      end
    end
  end

  describe '.log' do
    let(:email_template_name) { 'template_name' }
    let(:email_type) { :patron_contribution }
    let(:receiver) { create(:big_donor) }

    it 'creates a new email log' do
      expect do
        described_class.log(email_template_name:, email_type:, receiver:)
      end.to change(described_class, :count).by(1)
    end

    it 'sets the attributes correctly' do
      email_log = described_class.log(email_template_name:, email_type:, receiver:)
      expect(email_log.email_template_name).to eq(email_template_name)
      expect(email_log.email_type).to eq(email_type.to_s)
      expect(email_log.receiver).to eq(receiver)
    end
  end
end
