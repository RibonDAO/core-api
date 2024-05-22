# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  name       :string
#  status     :integer          default("inactive")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
FactoryBot.define do
  factory :tag do
    name { 'Tag 1' }
    status { :active }
  end
end
