module Mailers
  class SendDonationsEmailJob < ApplicationJob
    queue_as :mailers
    DONATIONS_COUNT_ENTRYPOINTS = [7].freeze

    def perform(donation:)
      user = donation.user
      donations_count = user.donations.count

      send_email(user, donations_count) if DONATIONS_COUNT_ENTRYPOINTS.include? donations_count
    end

    private

    def send_email(user, donations_count)
      SendgridWebMailer.send_email(receiver: user.email,
                                   dynamic_template_data: {},
                                   template_name: "user_donated_#{donations_count}_tickets_template_id",
                                   language: user.language).deliver_later
    end
  end
end
