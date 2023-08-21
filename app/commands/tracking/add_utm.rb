module Tracking
  class AddUtm < ApplicationCommand
    prepend SimpleCommand

    attr_reader :utm_source, :utm_medium, :utm_campaign, :trackable

    def initialize(utm_source:, utm_medium:, utm_campaign:, trackable:)
      @utm_source = utm_source
      @utm_medium = utm_medium
      @utm_campaign = utm_campaign
      @trackable = trackable
    end

    def call
      trackable.create_utm!(utm_params)
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end

    private

    def utm_params
      {
        source: utm_source,
        medium: utm_medium,
        campaign: utm_campaign
      }
    end
  end
end
