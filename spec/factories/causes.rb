# == Schema Information
#
# Table name: causes
#
#  id                      :bigint           not null, primary key
#  cover_image_description :string
#  main_image_description  :string
#  name                    :string
#  status                  :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
FactoryBot.define do
  factory :cause do
    name { 'Cause' }
    status { :active }
  end
end
