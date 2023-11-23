# frozen_string_literal: true

require 'uri'
require 'open-uri'

module Users
  class CreateProfile < ApplicationCommand
    prepend SimpleCommand

    attr_reader :data, :user, :profile

    def initialize(data:, user:)
      @data = data
      @user = user
    end

    def call
      with_exception_handle do
        @profile = UserProfile.find_or_initialize_by(user:)
        set_attributes
        @profile.save!
        @profile
      end
    end

    private

    def url
      data['picture'] || ''
    end

    def name
      data['name'] || ''
    end

    def grab_image(url)
      uri = URI.parse(url)
      raise StandardError, 'Invalid url format' unless uri.scheme && uri.host

      uri.open
    end

    def set_attributes
      profile.name = name if profile.name.blank?
      io = grab_image(url)
      filename = "photo#{user.id}.jpg"
      profile.photo.attach(io:, filename:) unless profile.photo.attached?
    end
  end
end
