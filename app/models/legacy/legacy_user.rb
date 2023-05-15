# == Schema Information
#
# Table name: legacy_users
#
#  id         :bigint           not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  legacy_id  :integer
#  user_id    :bigint
#
class LegacyUser < ApplicationRecord
  belongs_to :user, optional: true

  has_many :legacy_user_impacts
  has_many :legacy_contributions

  validates :email, :legacy_id, presence: true
end
