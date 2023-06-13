# == Schema Information
#
# Table name: donation_batches
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  batch_id    :bigint           not null
#  donation_id :bigint           not null
#
FactoryBot.define do
  factory :donation_batch do
    donation { build(:donation) }
    batch { build(:batch) }
  end
end
