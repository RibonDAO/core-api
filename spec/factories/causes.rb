# == Schema Information
#
# Table name: causes
#
#  id                      :bigint           not null, primary key
#  active                  :boolean          default(TRUE)
#  cover_image_description :string
#  main_image_description  :string
#  name                    :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
FactoryBot.define do
  factory :cause do
    name { 'Cause' }
    active { true }
  end
end
