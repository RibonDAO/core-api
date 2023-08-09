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
class Article < ApplicationRecord
  belongs_to :author
  has_one_attached :image

  enum language: {
    'en-US': 0,
    'pt-BR': 1
  }
end
