# frozen_string_literal: true

module Donations
  class CreateDonationsBatch < ApplicationCommand
    prepend SimpleCommand
    attr_reader :integration, :non_profit, :period

    def initialize(integration:, non_profit:, period:)
      @integration = integration
      @non_profit = non_profit
      @period = period
    end

    def call
      @donations = batch_donations
      return unless @donations.length.positive?

      create_batch_file

      batch = create_batch
      create_donations_batch(batch)
      batch
    end

    private

    def batch_donations
      donation_ids = BatchQueries.new(integration:, non_profit:, period:).donations_without_batch
      Donation.where(id: donation_ids)
    end

    def create_batch_file
      File.write("#{Rails.root}/app/lib/web3/utils/donation_batch.json", temporary_json.to_json)
    end

    def batch_file
      File.read("#{Rails.root}/app/lib/web3/utils/donation_batch.json")
    end

    def store_batch
      result = Web3::Storage::NftStorage::Actions.new.store(file: batch_file)

      OpenStruct.new(result.parsed_response).value['cid']
    end

    def temporary_json
      donations_json = []

      @donations.map do |donation|
        donations_json.push({
                              value: donation.value,
                              integration_id: donation.integration_id,
                              non_profit_id: donation.non_profit_id,
                              user_id: donation.user_id,
                              donation_id: donation.id,
                              user_hash: user_hash(donation&.user&.email),
                              integration_address: donation.integration.wallet_address,
                              non_profit_address: donation.non_profit.wallet_address,
                              timestamp: donation.created_at
                            })
      end
      donations_json
    end

    def create_batch
      Batch.create(cid: store_batch, amount: total_amount, reference_period: period)
    end

    def create_donations_batch(batch)
      @donations.map do |donation|
        DonationBatch.create(donation:, batch:)
      end
    end

    def total_amount
      @donations.sum(:value)
    end

    def user_hash(email)
      Web3::Utils::Converter.keccak(email) if email
    end
  end
end
