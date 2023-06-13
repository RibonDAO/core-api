# == Schema Information
#
# Table name: stories
#
#  id                :bigint           not null, primary key
#  active            :boolean
#  description       :text
#  image_description :string
#  position          :integer
#  title             :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  non_profit_id     :bigint           not null
#
class Story < ApplicationRecord
  extend Mobility

  translates :title, :description, :image_description, type: :string

  belongs_to :non_profit

  validates :title, :description, :position, :active, presence: true

  has_one_attached :image
end
