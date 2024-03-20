# frozen_string_literal: true

module Users
  class CreateAccount < ApplicationCommand
    prepend SimpleCommand

    attr_reader :data, :provider

    def initialize(data:, provider:)
      @data = data
      @provider = provider
    end

    def call
      with_exception_handle do
        email = data['email'] || data
        user = User.find_or_create_by(email:)

        account = Account.find_or_initialize_by(user:, provider:)
        account.assign_attributes(
          provider:,
          uid: email
        )
        account.save!
        account
      end
    end
  end
end
