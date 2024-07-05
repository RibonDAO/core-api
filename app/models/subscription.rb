# == Schema Information
#
# Table name: subscriptions
#
#  id                   :bigint           not null, primary key
#  cancel_date          :datetime
#  next_payment_attempt :datetime
#  payer_type           :string
#  payment_method       :string
#  platform             :string
#  receiver_type        :string
#  status               :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  external_id          :string
#  integration_id       :bigint
#  offer_id             :bigint
#  payer_id             :uuid
#  receiver_id          :bigint
#
class Subscription < ApplicationRecord
  belongs_to :payer, polymorphic: true
  belongs_to :receiver, polymorphic: true, optional: true
  belongs_to :offer, optional: true
  belongs_to :integration

  has_many :person_payments

  delegate :category, to: :offer

  enum status: {
    active: 0,
    inactive: 1,
    canceled: 2,
    payment_failed: 3
  }

  scope :active_from_club, lambda {
    joins(:offer).where(offers: { category: :club })
                 .joins(:person_payments)
                 .where('person_payments.created_at =
                        (SELECT MAX(person_payments.created_at)
                        FROM person_payments
                        WHERE person_payments.subscription_id = subscriptions.id)')
                 .group('subscriptions.id')
                 .where(status: %i[active canceled])
                 .where('person_payments.paid_date > ?
                  OR subscriptions.next_payment_attempt > ?', 1.month.ago, Time.zone.now)
  }

  def last_club_day
    next_payment_attempt || (person_payments.last&.paid_date&.+ 1.month)
  end

  def formatted_amount
    Money.from_cents(offer.price_cents, offer.currency).format || person_payments&.last&.formatted_amount
  end
end
