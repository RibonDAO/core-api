# == Schema Information
#
# Table name: contributions
#
#  id                  :bigint           not null, primary key
#  generated_fee_cents :integer
#  receiver_type       :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  person_payment_id   :bigint           not null
#  receiver_id         :bigint           not null
#
FactoryBot.define do
  factory :contribution do
    person_payment { build(:person_payment) }
    receiver { build(:non_profit) }
    generated_fee_cents { 100 }

    trait(:with_contribution_balance) do
      after(:create) do |contribution|
        create(:contribution_balance, contribution:)
      end
    end

    trait :with_paid_status do
      before(:create) do |contribution|
        contribution.person_payment = create(:person_payment, status: :paid)
      end
    end

    trait(:with_payment_in_blockchain) do
      after(:create) do |contribution|
        create(:person_blockchain_transaction, treasure_entry_status: :success,
                                               succeeded_at: contribution.created_at,
                                               person_payment: contribution.person_payment)
      end
    end

    trait(:feeable) do
      before(:create) do |contribution|
        contribution.person_payment = create(:person_payment,
                                             :with_payment_in_blockchain,
                                             status: :paid)
      end

      after(:create) do |contribution|
        create(:contribution_balance, contribution:)
      end
    end
  end
end
