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
FactoryBot.define do
  factory :non_profit_tag do
    non_profit { build(:non_profit) }
    tag { build(:tag) }
  end
end
