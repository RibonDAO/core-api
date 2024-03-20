# == Schema Information
#
# Table name: user_integration_collected_tickets
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  integration_id :bigint           not null
#  user_id        :bigint           not null
#
FactoryBot.define do
  factory :user_integration_collected_ticket do
    user { build(:user) }
    integration { build(:integration) }
  end
end
