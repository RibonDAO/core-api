# == Schema Information
#
# Table name: utms
#
#  id             :bigint           not null, primary key
#  campaign       :string
#  medium         :string
#  source         :string
#  trackable_type :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  trackable_id   :bigint
#
class Utm < ApplicationRecord
  belongs_to :trackable, polymorphic: true

  validates :source, presence: true
  validates :trackable_id, uniqueness: { scope: :trackable_type }
end
