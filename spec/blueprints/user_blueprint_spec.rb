require 'rails_helper'

RSpec.describe UserBlueprint, type: :blueprint do
  let(:user) { create(:user) }
  let(:user_blueprint) { described_class.render(user) }
  let(:user_blueprint_extended) { described_class.render(user, view: :extended) }

  it 'has the correct fields' do
    expect(user_blueprint).to include(:email.to_s)
  end

  it 'has the correct view' do
    expect(user_blueprint_extended).to include(:last_donated_cause.to_s)
    expect(user_blueprint_extended).to include(:last_donation_at.to_s)
  end
end
