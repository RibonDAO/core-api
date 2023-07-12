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
FactoryBot.define do
  factory :email_log do
    email_template_name { 'MyString' }
    email_type { 1 }
    status { 1 }
    receiver { create(:big_donor) }
  end
end
