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
