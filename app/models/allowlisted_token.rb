# == Schema Information
#
# Table name: allowlisted_tokens
#
#  id                   :bigint           not null, primary key
#  authenticatable_type :string           not null
#  exp                  :datetime
#  jti                  :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  authenticatable_id   :bigint           not null
#
class AllowlistedToken < ApplicationRecord
  belongs_to :authenticatable, polymorphic: true
end
