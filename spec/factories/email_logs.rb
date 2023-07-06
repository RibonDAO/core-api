# == Schema Information
#
# Table name: email_logs
#
#  id                     :bigint           not null, primary key
#  email_type             :integer
#  receiver_type          :string           not null
#  sendgrid_template_name :string
#  status                 :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  receiver_id            :string           not null
#
FactoryBot.define do
  factory :email_log do
    sendgrid_template_name { 'MyString' }
    email_type { 1 }
    status { 1 }
    receiver { create(:big_donor) }
  end
end
