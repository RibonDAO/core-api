# == Schema Information
#
# Table name: person_blockchain_transactions
#
#  id                    :bigint           not null, primary key
#  succeeded_at          :datetime
#  transaction_hash      :string
#  treasure_entry_status :integer          default("processing")
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  person_payment_id     :bigint
#
FactoryBot.define do
  factory :person_blockchain_transaction do
    treasure_entry_status { 0 }
    association :person_payment, factory: :person_payment
    transaction_hash { '0x0000000000000000000000000000000000000000000000000000000000000000' }
  end
end
