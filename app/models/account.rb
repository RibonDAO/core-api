# == Schema Information
#
# Table name: accounts
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  encrypted_password     :string
#  image                  :string
#  name                   :string
#  nickname               :string
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  tokens                 :json
#  uid                    :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :bigint           not null
#
class Account < ApplicationRecord
  include AuthenticatableModel

  belongs_to :user

  validates :uid, presence: true

  delegate :email, to: :user

  def self.create_user_for_provider(data, provider)
    user = User.find_or_create_by(email: data['email'])
    account = find_or_initialize_by(user:, provider:)
    account.assign_attributes(
      provider:,
      uid: data['email']
    )
    account.save!
    account
  end
end
