module Tracking
  class AddUtm < ApplicationCommand
    prepend SimpleCommand

    attr_reader :utm_source, :utm_medium, :utm_campaign, :trackable

    def initialize(utm_params:, trackable:)
      @utm_source = utm_params[:utm_source]
      @utm_medium = utm_params[:utm_medium]
      @utm_campaign = utm_params[:utm_campaign]
      @trackable = trackable
    end

    def call
      trackable.create_utm(source: utm_source, medium: utm_medium, campaign: utm_campaign)
    rescue StandardError => e
      Reporter.log(error: e, extra: { message: e.message })
    end
  end
end
