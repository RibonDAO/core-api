class PersonPaymentObserver < ActiveRecord::Observer
  def after_update(person_payment)
    Mailers::SendPersonPaymentEmailJob.perform_later(person_payment:) if processing_to_paid?(person_payment)

    if processing_to_paid_subscription?(person_payment)
      Events::PersonPayments::SendSuccededPaymentEventJob.perform_later(person_payment:)
    end

    if processing_to_failed?(person_payment)
      Events::PersonPayments::SendFailedPaymentEventJob.perform_later(person_payment:)
    end
  rescue StandardError
    nil
  end

  def after_create(person_payment)
    if person_payment.paid? && person_payment.subscription?
      Events::Club::SendSuccededPaymentEventJob.perform_later(person_payment:)
    end
    if person_payment.failed? && person_payment.subscription?
      Events::Club::SendFailedPaymentEventJob.perform_later(person_payment:)
    end
  rescue StandardError
    nil
  end

  def processing_to_paid__club_subscription?(person_payment)
    person_payment.previous_changes[:status] == %w[processing paid] &&
      person_payment.paid? &&
      person_payment.subscription.category == 'club'
  end

  def processing_to_paid?(person_payment)
    person_payment.previous_changes[:status] == %w[processing paid] &&
      person_payment.paid? &&
      !person_payment.crypto? &&
      person_payment.subscription.nil?
  end

  def processing_to_failed?(person_payment)
    person_payment.previous_changes[:status] == %w[processing failed] &&
      person_payment.failed? &&
      person_payment.subscription.present?
  end
end
