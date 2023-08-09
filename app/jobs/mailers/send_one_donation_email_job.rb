module Mailers
  class SendOneDonationEmailJob < ApplicationJob
    queue_as :mailers
    DONATIONS_COUNT_ENTRYPOINTS = [1].freeze

    def perform(donation:)
      user = donation.user
      donations_count = user.donations.count
      first_impact = impact_normalizer(donation.non_profit)
      send_email(user, donations_count, first_impact) if DONATIONS_COUNT_ENTRYPOINTS.include? donations_count
    end

    private

    def impact_normalizer(non_profit)
      Impact::Normalizer.new(
        non_profit,
        non_profit.impact_by_ticket
      ).normalize.join(' ')
    end

    def send_email(user, donations_count, first_impact)
      SendgridWebMailer.send_email(receiver: user.email,
                                   dynamic_template_data: { first_impact: },
                                   template_name: "user_donated_#{donations_count}_tickets_template_id",
                                   language: user.language).deliver_later
    end
  end
end
