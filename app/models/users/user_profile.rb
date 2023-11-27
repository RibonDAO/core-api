# == Schema Information
#
# Table name: user_profiles
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
class UserProfile < ApplicationRecord
  belongs_to :user

  has_one_attached :photo
end
