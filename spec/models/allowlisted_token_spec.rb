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
require 'rails_helper'

RSpec.describe AllowlistedToken, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
