# == Schema Information
#
# Table name: tasks
#
#  id         :bigint           not null, primary key
#  actions    :text
#  rules      :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Task, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
