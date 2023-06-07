require 'rails_helper'

RSpec.describe ContributionStatsBlueprint, type: :blueprint do
  let(:contribution) { create(:contribution) }
  let(:contribution_stats) { Service::Contributions::StatisticsService.new(contribution:).formatted_statistics }
  let(:contribution_blueprint) { described_class.render(contribution_stats) }

  it 'has the correct fields' do
    expect(contribution_blueprint).to include('initial_amount')
    expect(contribution_blueprint).to include('used_amount')
    expect(contribution_blueprint).to include('remaining_amount')
    expect(contribution_blueprint).to include('total_tickets')
    expect(contribution_blueprint).to include('avg_donations_per_person')
    expect(contribution_blueprint).to include('boost_amount')
    expect(contribution_blueprint).to include('total_increase_percentage')
    expect(contribution_blueprint).to include('total_amount_to_cause')
    expect(contribution_blueprint).to include('ribon_fee')
  end
end
