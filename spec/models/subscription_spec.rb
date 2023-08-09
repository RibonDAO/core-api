# == Schema Information
#
# Table name: subscriptions
#
#  id             :bigint           not null, primary key
#  cancel_date    :datetime
#  payer_type     :string
#  payment_method :string
#  platform       :string
#  receiver_type  :string
#  status         :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  external_id    :string
#  offer_id       :bigint
#  payer_id       :uuid
#  receiver_id    :uuid
#
require 'rails_helper'

RSpec.describe Subscription, type: :model do
  subject(:subscription) { create(:subscription) }

  describe 'validations' do
    it { is_expected.to belong_to(:payer) }
    it { is_expected.to belong_to(:receiver).optional }
    it { is_expected.to belong_to(:offer).optional }
  end
end
