# == Schema Information
#
# Table name: user_integration_collected_tickets
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  integration_id :bigint           not null
#  user_id        :bigint           not null
#
class UserIntegrationCollectedTicket < ApplicationRecord
  belongs_to :user
  belongs_to :integration
end
