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
#  status         :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  external_id    :string
#  offer_id       :uuid
#  payer_id       :uuid
#  receiver_id    :uuid
#
require 'rails_helper'

RSpec.describe Subscription, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
