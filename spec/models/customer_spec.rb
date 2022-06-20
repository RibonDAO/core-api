require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'ActiveRecord specification' do
    it { is_expected.to have_db_column(:id).of_type(:uuid) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:email).of_type(:string) }
    it { is_expected.to have_db_column(:customer_keys).of_type(:jsonb) }
  end

  describe 'Active record validation' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
  end

  describe '.valid?' do
    let(:customer) { build(:customer, customer_keys: { stripe: 'stripe_key', iugu: 'iugu key' }) }

    it { expect(customer).to be_valid }
  end

  describe '#save' do
    context 'when create customer' do
      let(:customer) { create(:customer, customer_keys: {}) }

      it { expect(customer.id).not_to be_nil }
      it { expect(customer.name).to eq 'a customer' }
      it { expect(customer.email).to eq 'customer@customer.com' }
      it { expect(customer.customer_keys).to be_empty }
    end
  end

  describe '#update' do
    context 'when update customer with customer keys' do
      let(:customer) { create(:customer, customer_keys: { stripe: 'stripe_key' }) }

      it { expect(customer.id).not_to be_nil }
      it { expect(customer.name).to eq 'a customer' }
      it { expect(customer.email).to eq 'customer@customer.com' }
      it { expect(customer.customer_keys['stripe']).to eq('stripe_key') }
    end
  end
end
