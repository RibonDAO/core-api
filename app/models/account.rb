class Account < ApplicationRecord
  include AuthenticatableModel

  belongs_to :user

  validates :uid, uniqueness: { case_sensitive: true }, presence: true

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
