# == Schema Information
#
# Table name: tasks
#
#  id                  :uuid             not null, primary key
#  actions             :string           not null
#  client              :string           default("web")
#  kind                :string           default("daily")
#  navigation_callback :string
#  title               :string           not null
#  visibility          :string           default("visible")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
require 'rails_helper'

RSpec.describe Task, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
