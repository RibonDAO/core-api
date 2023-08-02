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
class Subscription < ApplicationRecord
  belongs_to :payer, polymorphic: true
  belongs_to :receiver, polymorphic: true, optional: true
  belongs_to :offer, optional: true
end
