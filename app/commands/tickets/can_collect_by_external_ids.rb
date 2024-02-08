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
      external_ids.each do |external_id|
        return true unless Voucher.exists?(external_id:)
      end
      false
    end
  end
end
