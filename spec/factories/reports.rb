# == Schema Information
#
# Table name: reports
#
#  id         :bigint           not null, primary key
#  name       :string
#  link       :string
#  active     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :report do
    name { 'March' }
    link { 'http://marchreport.com' }
    active { true }
  end
end
