# == Schema Information
#
# Table name: tickets
#
#  id             :bigint           not null, primary key
#  category       :integer          default("daily")
#  platform       :string
#  source         :integer          default("integration")
#  status         :integer          default("collected")
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  external_id    :string
#  integration_id :bigint
#  user_id        :bigint           not null
#
class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :integration, optional: true

  has_one :utm, as: :trackable

  enum status: {
    collected: 0,
    to_collect: 1
  }

  enum category: {
    daily: 0,
    monthly: 1
  }

  enum source: {
    integration: 0,
    club: 1
  }
end
