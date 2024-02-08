# == Schema Information
#
# Table name: accounts
#
#  id                  :bigint           not null, primary key
#  confirmed_at        :datetime
#  deleted_at          :datetime
#  provider            :string
#  remember_created_at :datetime
#  tokens              :json
#  uid                 :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  user_id             :bigint           not null
#
class Account < ApplicationRecord
  include AuthenticatableModel

  belongs_to :user

  validates :uid, presence: true

  delegate :email, to: :user
end
