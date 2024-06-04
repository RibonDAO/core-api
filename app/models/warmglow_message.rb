# == Schema Information
#
# Table name: warmglow_messages
#
#  id         :bigint           not null, primary key
#  message    :string
#  status     :integer          default("inactive")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class WarmglowMessage < ApplicationRecord
  extend Mobility

  translates :message, type: :string

  enum status: {
    inactive: 0,
    active: 1
  }
end
