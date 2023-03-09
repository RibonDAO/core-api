# == Schema Information
#
# Table name: people
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Person < ApplicationRecord
  include UuidHelper

  has_one :crypto_user, dependent: :destroy
  has_one :customer, dependent: :destroy
  has_many :person_payments, dependent: :nullify
end
