# frozen_string_literal: true

module Tickets
  class CanCollectByExternalId < ApplicationCommand
    prepend SimpleCommand
    attr_reader :external_id

    def initialize(external_id:)
      @external_id = external_id
    end

    def call
      with_exception_handle do
        valid_external_id?
      end
    end

    private

    def valid_external_id?
      !Voucher.exists?(external_id:)
    end
  end
end
