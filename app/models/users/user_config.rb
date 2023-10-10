# == Schema Information
#
# Table name: user_configs
#
#  id                      :bigint           not null, primary key
#  allowed_email_marketing :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint           not null
#
class UserConfig < ApplicationRecord
  belongs_to :user

  validates :allowed_email_marketing, inclusion: { in: [true, false] }
end
