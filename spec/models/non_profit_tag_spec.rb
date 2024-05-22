# == Schema Information
#
# Table name: non_profit_tags
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  non_profit_id :bigint           not null
#  tag_id        :bigint           not null
#
require 'rails_helper'

RSpec.describe NonProfitTag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
