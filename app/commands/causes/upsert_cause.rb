# frozen_string_literal: true

module Causes
  class UpsertCause < ApplicationCommand
    prepend SimpleCommand
    include Web3

    attr_reader :cause_params

    def initialize(cause_params)
      @cause_params = cause_params
    end

    def call
      if cause_params[:id].present?
        update
      elsif cause_params[:name].present?
        create
      else
        errors.add(:message, I18n.t('causes.create_failed'))
      end
    end

    private

    def create
      create_pool
      Cause.create!(cause_params)
    rescue StandardError
      errors.add(:message, I18n.t('causes.create_failed'))
    end

    def update
      cause = Cause.find cause_params[:id]
      cause.update(cause_params)
      cause
    rescue StandardError
      errors.add(:message, I18n.t('causes.update_failed'))
    end

    def chain
      Chain.default
    end

    def token
      Token.default
    end

    def create_pool
      Web3::Contracts::RibonContract.new(chain:).create_pool(token: token.address)
    end
  end
end
