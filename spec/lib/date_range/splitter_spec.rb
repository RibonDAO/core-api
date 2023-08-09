# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DateRange::Splitter do
  describe '.split' do
    subject(:split) { described_class.new(start_date, end_date, intervals).split }

    let(:start_date) { Time.zone.local(2017, 1, 1) }
    let(:end_date)   { Time.zone.local(2017, 1, 31) }
    let(:intervals)  { 3 }

    it 'returns an array of hashes' do
      expect(split).to be_an Array
      expect(split.first).to be_a Hash
    end

    it 'returns the correct number of intervals' do
      expect(split.size).to eq intervals
    end

    it 'returns the correct start and end dates' do
      expect(split.first[:start_date]).to eq start_date
      expect(split.last[:end_date]).to eq end_date
    end

    context 'when the start date is the same as the end date' do
      let(:end_date) { start_date }

      it 'returns an array with 1 element' do
        expect(split.size).to eq 1
      end
    end

    context 'when the start date is after the end date' do
      let(:start_date) { end_date + 1.day }

      it 'returns an empty array' do
        expect(split).to be_empty
      end
    end

    context 'when the number of intervals is zero' do
      let(:intervals) { 0 }

      it 'returns an empty array' do
        expect(split).to be_empty
      end
    end

    context 'when the number of intervals is greater than the number of days' do
      let(:intervals) { 31 }

      it 'returns the correct number of intervals' do
        expect(split.size).to eq 30
      end
    end
  end
end
