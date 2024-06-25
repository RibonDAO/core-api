# frozen_string_literal: true

module Tickets
  class CanCollectByExternalIds < ApplicationCommand
    prepend SimpleCommand
    attr_reader :external_ids

    def initialize(external_ids:)
      @external_ids = external_ids
    end

    def call
      with_exception_handle do
        valid_external_ids?
      end
    end

    private

    def valid_external_ids?
      existing_vouchers = Voucher.where(external_id: external_ids)
      { can_collect: (existing_vouchers.size < external_ids.size),
        quantity: (external_ids.size - existing_vouchers.size) }
    end
  end
end
