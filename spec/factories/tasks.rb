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
FactoryBot.define do
  factory :task do
    title { 'My Task' }
    actions { 'causes_page_view' }
    kind { 'daily' }
    navigation_callback { '/causes' }
    visibility { 'visible' }
    client { 'web' }
  end
end
