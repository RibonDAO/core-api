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
FactoryBot.define do
  factory :article do
    author { build(:author) }
    title { 'My article' }
    published_at { '2023-03-01 15:42:30' }
    visible { false }
    link { 'https://ribon.io' }
    language { 0 }
  end
end
