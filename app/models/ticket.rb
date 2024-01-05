# == Schema Information
#
# Table name: tickets
#
#  id             :bigint           not null, primary key
#  platform       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  external_id    :string
#  integration_id :bigint           not null
#  user_id        :bigint           not null
#
class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :integration
end
