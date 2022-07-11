class Customer < ApplicationRecord
  include UuidHelper

  belongs_to :user
  belongs_to :people

  validates :email, presence: true
  validates :name, presence: true
end
