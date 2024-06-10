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
class NonProfitTag < ApplicationRecord
  belongs_to :non_profit
  belongs_to :tag
end
