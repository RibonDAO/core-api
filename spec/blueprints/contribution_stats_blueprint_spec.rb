require 'rails_helper'

RSpec.describe ContributionStatsBlueprint, type: :blueprint do
  let(:contribution) { create(:contribution) }
  let(:contribution_stats) { Service::Contributions::StatisticsService.new(contribution:).formatted_statistics }
  let(:contribution_blueprint) { described_class.render_as_json(contribution_stats) }

  it 'has the correct fields' do
    expect(contribution_blueprint.keys)
      .to match_array(%w[
                        initial_amount used_amount remaining_amount total_tickets
                        avg_donations_per_person boost_amount
                        total_increase_percentage total_amount_to_cause ribon_fee
                      ])
  end
end
