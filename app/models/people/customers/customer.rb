# == Schema Information
#
# Table name: customers
#
#  id            :uuid             not null, primary key
#  customer_keys :jsonb
#  email         :string           not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  person_id     :uuid
#  tax_id        :string
#  user_id       :bigint
#
class Customer < ApplicationRecord
  include UuidHelper
  validates :email, presence: true
  validates :name, presence: true

  belongs_to :user
  belongs_to :person, optional: true

  has_many :person_payments, as: :payer

  def blueprint
    CustomerBlueprint
  end

  def identification
    email
  end
end
