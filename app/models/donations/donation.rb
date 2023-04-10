# == Schema Information
#
# Table name: donations
#
#  id             :bigint           not null, primary key
#  platform       :string
#  value          :decimal(, )
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  integration_id :bigint           not null
#  non_profit_id  :bigint           not null
#  user_id        :bigint
#
class Donation < ApplicationRecord
  belongs_to :non_profit
  belongs_to :integration
  belongs_to :user

  has_one :donation_batch
  has_one :donation_contribution
  has_many :donation_blockchain_transactions

  enum platform: {
    web: 'web',
    app: 'app'
  }

  scope :created_between, lambda { |start_date, end_date|
                            where('created_at >= ? AND created_at <= ?', start_date, end_date)
                          }

  scope :for_cause, ->(cause_id) { joins(non_profit: :cause).where(causes: { id: cause_id }) }

  delegate :cause, to: :non_profit

  def donation_blockchain_transaction
    donation_blockchain_transactions.last
  end

  def create_donation_blockchain_transaction(transaction_hash:, chain:)
    donation_blockchain_transactions.create(transaction_hash:, chain:)
  end

  def impact
    "#{impact_value} #{non_profit.impact_description}"
  end

  def impact_value
    (value / non_profit.impact_for.usd_cents_to_one_impact_unit).to_i
  rescue StandardError
    0
  end
end
