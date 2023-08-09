require 'rails_helper'

RSpec.describe VoucherBlueprint, type: :blueprint do
  let(:voucher) { create(:voucher) }
  let(:voucher_blueprint) { described_class.render(voucher) }

  it 'has the correct fields' do
    expect(voucher_blueprint).to include(:external_id.to_s)
    expect(voucher_blueprint).to include(:callback_url.to_s)
  end
end
