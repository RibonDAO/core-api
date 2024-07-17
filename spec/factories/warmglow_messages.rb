# == Schema Information
#
# Table name: warmglow_messages
#
#  id         :bigint           not null, primary key
#  message    :text
#  status     :integer          default("inactive")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :warmglow_message do
    message { 'Message 1' }
    status { :active }
  end
end
