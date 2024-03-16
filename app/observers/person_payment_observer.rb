class PersonPaymentObserver < ActiveRecord::Observer
  def after_update(person_payment)
    send_person_payment_email(person_payment) if processing_to_paid_non_subscription?(person_payment)
    send_failed_payment_event(person_payment) if processing_to_failed?(person_payment)

    if processing_to_paid_subscription?(person_payment)
      give_monthly_tickets(person_payment)
      give_daily_tickets(person_payment)
    end
  rescue StandardError
    nil
  end

  def after_create(person_payment)
    if person_payment.paid? && person_payment.subscription?
      give_monthly_tickets(person_payment)
    elsif person_payment.failed? && person_payment.subscription?
      Events::Club::SendFailedPaymentEventJob.perform_later(person_payment:)
    end
  rescue StandardError
    nil
  end

  def processing_to_paid?(person_payment)
    person_payment.previous_changes[:status] == %w[processing paid] &&
      person_payment.paid? &&
      !person_payment.crypto?
  end

  def processing_to_paid_non_subscription?(person_payment)
    processing_to_paid?(person_payment) && person_payment.subscription.nil?
  end

  def processing_to_paid_subscription?(person_payment)
    processing_to_paid?(person_payment) && person_payment.subscription.present?
  end

  def processing_to_failed?(person_payment)
    person_payment.previous_changes[:status] == %w[processing failed] &&
      person_payment.failed? &&
      person_payment.subscription.present?
  end

  private

  def send_person_payment_email(person_payment)
    Mailers::SendPersonPaymentEmailJob.perform_later(person_payment:)
  end

  def send_failed_payment_event(person_payment)
    Events::PersonPayments::SendFailedPaymentEventJob.perform_later(person_payment:)
  end

  def give_monthly_tickets(person_payment)
    Tickets::GenerateClubMonthlyTicketsJob.perform_later(
      user: person_payment.payer.user,
      platform: person_payment.subscription.platform,
      quantity: person_payment.subscription.offer.plan.monthly_tickets,
      source: :club
    )
  end

  def give_daily_tickets(person_payment)
    Tickets::GenerateClubDailyTicketsJob.perform_later(
      user: person_payment.payer.user,
      platform: person_payment.subscription.platform,
      quantity: person_payment.subscription.offer.plan.daily_tickets,
      source: :club
    )
  end
end
