# == Schema Information
#
# Table name: articles
#
#  id           :bigint           not null, primary key
#  language     :integer          default("en-US")
#  link         :string
#  published_at :datetime
#  title        :string
#  visible      :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  author_id    :bigint           not null
#
require 'rails_helper'

RSpec.describe Article, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
