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
#  tax_id        :string
#  user_id       :bigint
#
class Customer < ApplicationRecord
  include UuidHelper
  validates :email, presence: true
  validates :name, presence: true

  belongs_to :user

  has_many :person_payments, as: :payer
  has_many :contributions, through: :person_payments

  def blueprint
    CustomerBlueprint
  end

  def identification
    email
  end
end
