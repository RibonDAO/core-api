# == Schema Information
#
# Table name: impression_cards
#
#  id          :bigint           not null, primary key
#  cta_text    :string           default(""), not null
#  cta_url     :string           default(""), not null
#  description :string           default(""), not null
#  headline    :string           default(""), not null
#  title       :string           default(""), not null
#  video_url   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class ImpressionCard < ApplicationRecord
  extend Mobility

  translates :title, :headline, :description, :cta_text, :cta_url, :video_url, type: :string

  has_one_attached :image

  validates :title, :headline, :description, :cta_text, :cta_url, presence: true
end
