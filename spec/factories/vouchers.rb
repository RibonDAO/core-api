# == Schema Information
#
# Table name: vouchers
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  donation_id    :bigint
#  external_id    :string
#  integration_id :bigint           not null
#
FactoryBot.define do
  factory :voucher do
    external_id { 'external_id' }
    integration { build(:integration) }
    donation { build(:donation) }
  end
end
